//
//  KNCache.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit

extension KNKesherConfiguration {
    
    public struct KNCache {
        public static let OriginalFormatName = "original"
        public enum ErrorCode : Int {
            case ObjectNotFound = -100
            case FormatNotFound = -101
        }
    }
}
class ObjectWrapper : NSObject {
    let value: Any
    init(value: Any) {
        self.value = value
    }
}


public class KNCache<T : DataConvertible where T.Result == T, T : DataRepresentable> {
    let name : String
    let memoryWarningObserver : NSObjectProtocol!
    public init(name : String) {
        self.name = name
        let notifications = NSNotificationCenter.defaultCenter()
        // Using block-based observer to avoid subclassing NSObject
        memoryWarningObserver = notifications.addObserverForName(UIApplicationDidReceiveMemoryWarningNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { [unowned self] (notification : NSNotification!) -> Void in
                self.onMemoryWarning()
            }
        )
        var originalFormat = Format<T>(name: KNKesherConfiguration.KNCache.OriginalFormatName)
        self.addFormat(originalFormat)
    }
    
    deinit {
        let notifications = NSNotificationCenter.defaultCenter()
        notifications.removeObserver(memoryWarningObserver, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    public func set(#value : T, key: String, formatName : String = KNKesherConfiguration.KNCache.OriginalFormatName, success succeed : ((T) -> ())? = nil) {
        if let (format, memoryCache, diskCache) = self.formats[formatName] {
            self.format(value: value, format: format) { formattedValue in
                let wrapper = ObjectWrapper(value: formattedValue)
                memoryCache.setObject(wrapper, forKey: key)
                // Value data is sent as @autoclosure to be executed in the disk cache queue.
                diskCache.setData(self.dataFromValue(formattedValue, format: format), key: key)
                succeed?(formattedValue)
            }
        } else {
            assertionFailure("Can't set value before adding format")
        }
    }
    
    public func fetch(#key : String, formatName : String = KNKesherConfiguration.KNCache.OriginalFormatName, failure fail : KNFetch<T>.Failer? = nil, success succeed : KNFetch<T>.Succeeder? = nil) -> KNFetch<T> {
        let fetch = KNCache.buildFetch(failure: fail, success: succeed)
        if let (format, memoryCache, diskCache) = self.formats[formatName] {
            if let wrapper = memoryCache.objectForKey(key) as? ObjectWrapper {
                if let result = wrapper.value as? T {
                    fetch.succeed(result)
                    diskCache.updateAccessDate(dataFromValue(result, format: format), key: key)
                    return fetch
                }
            }
            
            self.fetchFromDiskCache(diskCache, key: key, memoryCache: memoryCache, failure: { error in
                fetch.fail(error)
                }) { value in
                    fetch.succeed(value)
            }
            
        } else {
            let localizedFormat = NSLocalizedString("Format %@ not found", comment: "Error description")
            let description = String(format:localizedFormat, formatName)
            let error = errorWithCode(KNKesherConfiguration.KNCache.ErrorCode.FormatNotFound.rawValue, description: description)
            fetch.fail(error)
        }
        return fetch
    }
    
    public func fetch(#fetcher : KNFetcher<T>, formatName : String = KNKesherConfiguration.KNCache.OriginalFormatName, failure fail : KNFetch<T>.Failer? = nil, success succeed : KNFetch<T>.Succeeder? = nil) -> KNFetch<T> {
        let key = fetcher.key
        let fetch = KNCache.buildFetch(failure: fail, success: succeed)
        self.fetch(key: key, formatName: formatName, failure: { error in
            if error?.code == KNKesherConfiguration.KNCache.ErrorCode.FormatNotFound.rawValue {
                fetch.fail(error)
            }
            
            if let (format, _, _) = self.formats[formatName] {
                self.fetchAndSet(fetcher, format: format, failure: {error in
                    fetch.fail(error)
                    }) {value in
                        fetch.succeed(value)
                }
            }
            
            // Unreachable code. Formats can't be removed from Cache.
            }) { value in
                fetch.succeed(value)
        }
        return fetch
    }
    
    public func remove(#key : String, formatName : String = KNKesherConfiguration.KNCache.OriginalFormatName) {
        if let (_, memoryCache, diskCache) = self.formats[formatName] {
            memoryCache.removeObjectForKey(key)
            diskCache.removeData(key)
        }
    }
    
    public func removeAll() {
        for (_, (_, memoryCache, diskCache)) in self.formats {
            memoryCache.removeAllObjects()
            diskCache.removeAllData()
        }
    }
    
    // MARK: Notifications
    
    func onMemoryWarning() {
        for (_, (_, memoryCache, _)) in self.formats {
            memoryCache.removeAllObjects()
        }
    }
    
    // MARK: Formats
    
    var formats : [String : (Format<T>, NSCache, KNDiskCache)] = [:]
    
    public func addFormat(format : Format<T>) {
        let name = format.name
        let formatPath = self.formatPath(formatName: name)
        let memoryCache = NSCache()
        let diskCache = KNDiskCache(path: formatPath, capacity : format.diskCapacity)
        self.formats[name] = (format, memoryCache, diskCache)
    }
    
    // MARK: Internal
    
    lazy var cachePath : String = {
        let basePath = KNDiskCache.basePath()
        let cachePath = basePath.stringByAppendingPathComponent(self.name)
        return cachePath
        }()
    
    func formatPath(#formatName : String) -> String {
        let formatPath = self.cachePath.stringByAppendingPathComponent(formatName)
        var error : NSError? = nil
        let success = NSFileManager.defaultManager().createDirectoryAtPath(formatPath, withIntermediateDirectories: true, attributes: nil, error: &error)
        if (!success) {
            KNLogger.error("Failed to create directory \(formatPath)", error)
        }
        return formatPath
    }
    
    // MARK: Private
    
    func dataFromValue(value : T, format : Format<T>) -> NSData? {
        if let data = format.convertToData?(value) {
            return data
        }
        return value.asData()
    }
    
    private func fetchFromDiskCache(diskCache : KNDiskCache, key : String, memoryCache : NSCache, failure fail : ((NSError?) -> ())?, success succeed : (T) -> ()) {
        diskCache.fetchData(key, failure: { error in
            if let block = fail {
                if (error?.code == NSFileReadNoSuchFileError) {
                    let localizedFormat = NSLocalizedString("Object not found for key %@", comment: "Error description")
                    let description = String(format:localizedFormat, key)
                    let error = errorWithCode(KNKesherConfiguration.KNCache.ErrorCode.ObjectNotFound.rawValue, description: description)
                    block(error)
                } else {
                    block(error)
                }
            }
            }) { data in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var value = T.convertFromData(data)
                    if let value = value {
                        let descompressedValue = self.decompressedImageIfNeeded(value)
                        dispatch_async(dispatch_get_main_queue(), {
                            succeed(descompressedValue)
                            let wrapper = ObjectWrapper(value: descompressedValue)
                            memoryCache.setObject(wrapper, forKey: key)
                        })
                    }
                })
        }
    }
    
    private func fetchAndSet(fetcher : KNFetcher<T>, format : Format<T>, failure fail : ((NSError?) -> ())?, success succeed : (T) -> ()) {
        fetcher.fetch(failure: { error in
            let _ = fail?(error)
            }) { value in
                self.set(value: value, key: fetcher.key, formatName: format.name, success: succeed)
        }
    }
    
    private func format(#value : T, format : Format<T>, success succeed : (T) -> ()) {
        // HACK: Ideally Cache shouldn't treat images differently but I can't think of any other way of doing this that doesn't complicate the API for other types.
        if format.isIdentity && !(value is UIImage) {
            succeed(value)
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var formatted = format.apply(value)
                
                if let formattedImage = formatted as? UIImage {
                    let originalImage = value as? UIImage
                    if formattedImage === originalImage {
                        formatted = self.decompressedImageIfNeeded(formatted)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    succeed(formatted)
                }
            }
        }
    }
    
    private func decompressedImageIfNeeded(value : T) -> T {
        if let image = value as? UIImage {
            let decompressedImage = image.decompressedImage() as? T
            return decompressedImage!
        }
        return value
    }
    
    private class func buildFetch(failure fail : KNFetch<T>.Failer? = nil, success succeed : KNFetch<T>.Succeeder? = nil) -> KNFetch<T> {
        let fetch = KNFetch<T>()
        if let succeed = succeed {
            fetch.onSuccess(succeed)
        }
        if let fail = fail {
            fetch.onFailure(fail)
        }
        return fetch
    }
    
    // MARK: Convenience fetch
    // Ideally we would put each of these in the respective fetcher file as a Cache extension. Unfortunately, this fails to link when using the framework in a project as of Xcode 6.1.
    
    public func fetch(#key : String, value getValue : @autoclosure () -> T.Result, formatName : String = KNKesherConfiguration.KNCache.OriginalFormatName, success succeed : KNFetch<T>.Succeeder? = nil) -> KNFetch<T> {
        let fetcher = KNSimpleFetcher<T>(key: key, value: getValue)
        return self.fetch(fetcher: fetcher, formatName: formatName, success: succeed)
    }
    
    public func fetch(#path : String, formatName : String = KNKesherConfiguration.KNCache.OriginalFormatName,  failure fail : KNFetch<T>.Failer? = nil, success succeed : KNFetch<T>.Succeeder? = nil) -> KNFetch<T> {
        let fetcher = KNDiskFetcher<T>(path: path)
        return self.fetch(fetcher: fetcher, formatName: formatName, failure: fail, success: succeed)
    }
    
    public func fetch(#URL : NSURL, formatName : String = KNKesherConfiguration.KNCache.OriginalFormatName,  failure fail : KNFetch<T>.Failer? = nil, success succeed : KNFetch<T>.Succeeder? = nil) -> KNFetch<T> {
        let fetcher = KNNetworkFetcher<T>(URL: URL)
        return self.fetch(fetcher: fetcher, formatName: formatName, failure: fail, success: succeed)
    }
    
}