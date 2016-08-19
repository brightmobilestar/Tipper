//
//  KNDiskCache.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import Foundation

public class KNDiskCache {
    
    public class func basePath() -> String {
        let cachesPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let pathComponent = KNKesherConfiguration.Namespace
        let basePath = cachesPath.stringByAppendingPathComponent(pathComponent)
        return basePath
    }
    
    public let path : String
    public var size : UInt64 = 0
    public var capacity : UInt64 = 0 {
        didSet {
            dispatch_async(self.cacheQueue, {
                self.controlCapacity()
            })
        }
    }
    
    public lazy var cacheQueue : dispatch_queue_t = {
        let queueName = KNKesherConfiguration.Namespace + "." + self.path.lastPathComponent
        let cacheQueue = dispatch_queue_create(queueName, nil)
        return cacheQueue
        }()
    
    public init(path : String, capacity : UInt64 = UINT64_MAX) {
        self.path = path
        self.capacity = capacity
        dispatch_async(self.cacheQueue, {
            self.calculateSize()
            self.controlCapacity()
        })
    }
    
    public func setData(getData : @autoclosure () -> NSData?, key : String) {
        dispatch_async(cacheQueue, {
            self.setDataSync(getData, key: key)
        })
    }
    
    public func fetchData(key : String, failure fail : ((NSError?) -> ())? = nil, success succeed : (NSData) -> ()) {
        dispatch_async(cacheQueue, {
            let path = self.pathForKey(key)
            var error: NSError? = nil
            if let data = NSData(contentsOfFile: path, options: NSDataReadingOptions.allZeros, error: &error) {
                dispatch_async(dispatch_get_main_queue(), {
                    succeed(data)
                })
                self.updateDiskAccessDateAtPath(path)
            } else if let block = fail {
                dispatch_async(dispatch_get_main_queue(), {
                    block(error)
                })
            }
        })
    }
    
    public func removeData(key : String) {
        dispatch_async(cacheQueue, {
            let fileManager = NSFileManager.defaultManager()
            let path = self.pathForKey(key)
            let attributesOpt : NSDictionary? = fileManager.attributesOfItemAtPath(path, error: nil)
            var error: NSError? = nil
            let success = fileManager.removeItemAtPath(path, error:&error)
            if (success) {
                if let attributes = attributesOpt {
                    self.size -= attributes.fileSize()
                }
            } else {
               
            }
        })
    }
    
    public func removeAllData() {
        let fileManager = NSFileManager.defaultManager()
        let cachePath = self.path
        dispatch_async(cacheQueue, {
            var error: NSError? = nil
            if let contents = fileManager.contentsOfDirectoryAtPath(cachePath, error: &error) as? [String] {
                for pathComponent in contents {
                    let path = cachePath.stringByAppendingPathComponent(pathComponent)
                    if !fileManager.removeItemAtPath(path, error: &error) {
                        
                    }
                }
                self.calculateSize()
            }
        })
    }
    
    public func updateAccessDate(getData : @autoclosure () -> NSData?, key : String) {
        dispatch_async(cacheQueue, {
            let path = self.pathForKey(key)
            let fileManager = NSFileManager.defaultManager()
            if (!self.updateDiskAccessDateAtPath(path) && !fileManager.fileExistsAtPath(path)){
                let data = getData()
                self.setDataSync(data, key: key)
            }
        })
    }
    
    public func pathForKey(key : String) -> String {
        var escapedFilename = key.escapedFilename()
        let filename = countElements(escapedFilename) < Int(NAME_MAX) ? escapedFilename : key.MD5Filename()
        let keyPath = self.path.stringByAppendingPathComponent(filename)
        return keyPath
    }
    
    // MARK: Private functions
    private func calculateSize() {
        let fileManager = NSFileManager.defaultManager()
        size = 0
        let cachePath = self.path
        var error : NSError?
        if let contents = fileManager.contentsOfDirectoryAtPath(cachePath, error: &error) as? [String] {
            for pathComponent in contents {
                let path = cachePath.stringByAppendingPathComponent(pathComponent)
                if let attributes : NSDictionary = fileManager.attributesOfItemAtPath(path, error: &error) {
                    size += attributes.fileSize()
                }
            }
        }  
    }
    
    private func controlCapacity() {
        if self.size <= self.capacity { return }
        
        let fileManager = NSFileManager.defaultManager()
        let cachePath = self.path
        fileManager.enumerateContentsOfDirectoryAtPath(cachePath, orderedByProperty: NSURLContentModificationDateKey, ascending: true) { (URL : NSURL, _, inout stop : Bool) -> Void in
            if let path = URL.path {
                self.removeFileAtPath(path)
                stop = self.size <= self.capacity
            }
        }
    }
    
    private func setDataSync(getData : @autoclosure () -> NSData?, key : String) {
        let path = self.pathForKey(key)
        var error: NSError?
        if let data = getData() {
            let fileManager = NSFileManager.defaultManager()
            let previousAttributes : NSDictionary? = fileManager.attributesOfItemAtPath(path, error: nil)
            let success = data.writeToFile(path, options: NSDataWritingOptions.AtomicWrite, error:&error)
            if (!success) {
                KNLogger.error("Failed to write key \(key)", error)
            }
            if let attributes = previousAttributes {
                self.size -= attributes.fileSize()
            }
            self.size += data.length
            self.controlCapacity()
        } else {
            KNLogger.error("Failed to get data for key \(key)")
        }
    }
    
    private func updateDiskAccessDateAtPath(path : String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let now = NSDate()
        var error : NSError?
        let success = fileManager.setAttributes([NSFileModificationDate : now], ofItemAtPath: path, error: &error)
        if !success {
            KNLogger.error("Failed to update access date", error)
        }
        return success
    }
    
    private func removeFileAtPath(path:String) {
        var error : NSError?
        let fileManager = NSFileManager.defaultManager()
        if let attributes : NSDictionary = fileManager.attributesOfItemAtPath(path, error: &error) {
            let modificationDate = attributes.fileModificationDate()
            let fileSize = attributes.fileSize()
            if fileManager.removeItemAtPath(path, error: &error) {
                self.size -= fileSize
            } else {
                KNLogger.error("Failed to remove file", error)
            }
        } else {
            KNLogger.error("Failed to remove file", error)
        }
    }
}