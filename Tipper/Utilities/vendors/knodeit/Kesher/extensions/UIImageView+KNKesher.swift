//
//  UIImageView+KNKesher.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit

public extension UIImageView {
    
    public var kesher_format : Format<UIImage> {
        let viewSize = self.bounds.size
        assert(viewSize.width > 0 && viewSize.height > 0, "[\(reflect(self).summary) \(__FUNCTION__)]: UImageView size is zero. Set its frame, call sizeToFit or force layout first.")
        let scaleMode = self.scaleMode
        return KNKesherConfiguration.UIKit.formatWithSize(viewSize, scaleMode: scaleMode)
    }
    

    
    
    public func loadImageFromURL(URL: NSURL, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, failure fail : ((NSError?) -> ())? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = KNNetworkFetcher<UIImage>(URL: URL)
        self.setImageFromFetcher(fetcher, placeholder: placeholder, format: format, failure: fail, success: succeed)
    }
    
    public func loadImage(image: @autoclosure () -> UIImage, key : String, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = KNSimpleFetcher<UIImage>(key: key, value: image)
        self.setImageFromFetcher(fetcher, placeholder: placeholder, format: format, success: succeed)
    }
    
    public func loadImageFromFile(path : String, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, failure fail : ((NSError?) -> ())? = nil, success succeed : ((UIImage) -> ())? = nil) {
        let fetcher = KNDiskFetcher<UIImage>(path: path)
        self.setImageFromFetcher(fetcher, placeholder: placeholder, format: format, failure: fail, success: succeed)
    }
    
    public func setImageFromFetcher(fetcher : KNFetcher<UIImage>,
        placeholder : UIImage? = nil,
        format : Format<UIImage>? = nil,
        failure fail : ((NSError?) -> ())? = nil,
        success succeed : ((UIImage) -> ())? = nil) {
            
            self.cancelSetImage()
            
            self.privateFetcher = fetcher
            
            let didSetImage = self.fetchImageForFetcher(fetcher, format: format, failure: fail, success: succeed)
            
            if didSetImage { return }
             if let placeholder = placeholder {
                self.image = placeholder
            }
            
    }
    
    public func cancelSetImage() {
        if let fetcher = self.privateFetcher {
            fetcher.cancelFetch()
            self.privateFetcher = nil
        }
    }
    
    // MARK: Internal
    var privateFetcher : KNFetcher<UIImage>! {
        get {
            let wrapper = objc_getAssociatedObject(self, &KNKesherConfiguration.UIKit.SetImageFetcherKey) as? ObjectWrapper
            let fetcher = wrapper?.value as? KNFetcher<UIImage>
            return fetcher
        }
        set (fetcher) {
            var wrapper : ObjectWrapper?
            if let fetcher = fetcher {
                wrapper = ObjectWrapper(value: fetcher)
            }
            objc_setAssociatedObject(self, &KNKesherConfiguration.UIKit.SetImageFetcherKey, wrapper, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    public var scaleMode : ImageResizer.ScaleMode {
        switch (self.contentMode) {
        case .ScaleToFill:
            return .Fill
        case .ScaleAspectFit:
            return .AspectFit
        case .ScaleAspectFill:
            return .AspectFill
        case .Redraw, .Center, .Top, .Bottom, .Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight:
            return .None
        }
    }
    
    func fetchImageForFetcher(fetcher : KNFetcher<UIImage>, format : Format<UIImage>? = nil, failure fail : ((NSError?) -> ())?, success succeed : ((UIImage) -> ())?) -> Bool {
        let cache = Shared.imageCache
        let format = format ?? self.kesher_format
        if cache.formats[format.name] == nil {
            cache.addFormat(format)
        }
        var animated = false
        let fetch = cache.fetch(fetcher: fetcher, formatName: format.name, failure: {[weak self] error in
            if let strongSelf = self {
                if strongSelf.kesher_shouldCancelForKey(fetcher.key) { return }
                
                strongSelf.privateFetcher = nil
                
                fail?(error)
            }
            }) { [weak self] image in
                if let strongSelf = self {                    
                    if strongSelf.kesher_shouldCancelForKey(fetcher.key) { return }
                    
                    //TODO
                    strongSelf.kesher_setImage(image, animated:animated, success:succeed)
                }
        }
        animated = true
        return fetch.hasSucceeded
    }
    //this sets the image after it has become available and animated it in
    func kesher_setImage(image : UIImage, animated : Bool, success succeed : ((UIImage) -> ())?) {
        self.privateFetcher = nil
          if let succeed = succeed {
            succeed(image)
        } else {

            let duration : NSTimeInterval = animated ? KNKesherConfiguration.AnimationDuration : 0
            UIView.transitionWithView(self, duration: duration, options: .TransitionCrossDissolve, animations: {
               //TODO here is where the actual image is loaded
               self.image = image
                }, completion: nil)
        }
    }
    
    func kesher_shouldCancelForKey(key:String) -> Bool {
        if self.privateFetcher?.key == key { return false }
        
        KNLogger.error("Cancelled set image for \(key.lastPathComponent)")
        return true
    }
    
}

