//
//  UIImage+KNKesher.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit

extension UIImage {
    
    func imageByScalingToSize(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, !hasAlpha(), 0.0)
        drawInRect(CGRectMake(0, 0, toSize.width, toSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func hasAlpha() -> Bool {
        let alpha = CGImageGetAlphaInfo(self.CGImage)
        switch alpha {
        case .First, .Last, .PremultipliedFirst, .PremultipliedLast, .Only:
            return true
        case .None, .NoneSkipFirst, .NoneSkipLast:
            return false
        }
    }
    
    func kesher_data(compressionQuality: Float = 1.0) -> NSData! {
        let hasAlpha = self.hasAlpha()
        let data = hasAlpha ? UIImagePNGRepresentation(self) : UIImageJPEGRepresentation(self, CGFloat(compressionQuality))
        return data
    }
    
    func decompressedImage() -> UIImage! {
        let originalImageRef = self.CGImage
        let originalBitmapInfo = CGImageGetBitmapInfo(originalImageRef)
        let alphaInfo = CGImageGetAlphaInfo(originalImageRef)

        var bitmapInfo = originalBitmapInfo
        switch (alphaInfo) {
        case .None:
            bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask
            bitmapInfo |= CGBitmapInfo(CGImageAlphaInfo.NoneSkipFirst.rawValue)
        case .PremultipliedFirst, .PremultipliedLast, .NoneSkipFirst, .NoneSkipLast:
            break
        case .Only, .Last, .First: // Unsupported
            return self
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let pixelSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale)
        if let context = CGBitmapContextCreate(nil, UInt(pixelSize.width), UInt(pixelSize.height), CGImageGetBitsPerComponent(originalImageRef), 0, colorSpace, bitmapInfo) {
            
            let imageRect = CGRectMake(0, 0, pixelSize.width, pixelSize.height)
            UIGraphicsPushContext(context)

            CGContextTranslateCTM(context, 0, pixelSize.height)
            CGContextScaleCTM(context, 1.0, -1.0)

            self.drawInRect(imageRect)
            UIGraphicsPopContext()
            let decompressedImageRef = CGBitmapContextCreateImage(context)
            
            let scale = UIScreen.mainScreen().scale
            let image = UIImage(CGImage: decompressedImageRef, scale:scale, orientation:UIImageOrientation.Up)
            
            return image
            
        } else {
            return self
        }
    }    
    
}

