//
//  UIView+KNKesher.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import UIKit

public extension KNKesherConfiguration {
    
    public struct UIKit {
        
        static func formatWithSize(size : CGSize, scaleMode : ImageResizer.ScaleMode, allowUpscaling: Bool = true) -> Format<UIImage> {
            let name = "auto-\(size.width)x\(size.height)-\(scaleMode.rawValue)"
            let cache = Shared.imageCache
            if let (format,_,_) = cache.formats[name] {
                return format
            }
            
            var format = Format<UIImage>(name: name,
                diskCapacity: KNKesherConfiguration.UIKit.DefaultFormat.DiskCapacity) {
                    let resizer = ImageResizer(size:size,
                        scaleMode: scaleMode,
                        allowUpscaling: allowUpscaling,
                        compressionQuality: KNKesherConfiguration.UIKit.DefaultFormat.CompressionQuality)
                    return resizer.resizeImage($0)
            }
            format.convertToData = {(image : UIImage) -> NSData in
                image.kesher_data(compressionQuality: KNKesherConfiguration.UIKit.DefaultFormat.CompressionQuality)
            }
            return format
        }
        
        public struct DefaultFormat {
            
            public static let DiskCapacity : UInt64 = 10 * 1024 * 1024
            public static let CompressionQuality : Float = 1.0
            
        }
        
        static var SetImageFetcherKey = 0
        static var SetBackgroundImageFetcherKey = 1
    }
    
}
