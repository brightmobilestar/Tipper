//
//  KNFormat.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//
import UIKit

public struct Format<T> {
    
    public let name : String
    
    public let diskCapacity : UInt64
    
    public var transform : ((T) -> (T))?
    
    public var convertToData : (T -> NSData)?
    
    public init(name : String, diskCapacity : UInt64 = UINT64_MAX, transform : ((T) -> (T))? = nil) {
        self.name = name
        self.diskCapacity = diskCapacity
        self.transform = transform
    }
    
    public func apply(value : T) -> T {
        var transformed = value
        if let transform = self.transform {
            transformed = transform(value)
        }
        return transformed
    }
    
    var isIdentity : Bool {
        return self.transform == nil
    }
    
}

public struct ImageResizer {
    
    public enum ScaleMode : String {
        case Fill = "fill", AspectFit = "aspectfit", AspectFill = "aspectfill", None = "none"
    }
    
    public typealias T = UIImage
    
    public let allowUpscaling : Bool
    
    public let size : CGSize
    
    public let scaleMode: ScaleMode
    
    public let compressionQuality : Float
    
    public init(size : CGSize = CGSizeZero, scaleMode : ScaleMode = .None, allowUpscaling: Bool = true, compressionQuality : Float = 1.0) {
        self.size = size
        self.scaleMode = scaleMode
        self.allowUpscaling = allowUpscaling
        self.compressionQuality = compressionQuality
    }
    
    public func resizeImage(image: UIImage) -> UIImage {
        
        var resizeToSize: CGSize
        switch self.scaleMode {
        case .Fill:
            resizeToSize = self.size
        case .AspectFit:
            resizeToSize = image.size.aspectFitSize(self.size)
        case .AspectFill:
            resizeToSize = image.size.aspectFillSize(self.size)
        case .None:
            return image
        }
        assert(self.size.width > 0 && self.size.height > 0, "Expected non-zero size. Use ScaleMode.None to avoid resizing.")
        
        //scale up?
        if (!self.allowUpscaling) {
            if (resizeToSize.width > image.size.width || resizeToSize.height > image.size.height) {
                return image
            }
        }

        if (resizeToSize.width == image.size.width && resizeToSize.height == image.size.height) {
            return image
        }
        let resizedImage = image.imageByScalingToSize(resizeToSize)
        return resizedImage
 
    }
}

