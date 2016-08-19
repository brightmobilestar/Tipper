//
//  KNImageProcessor.swift
//  CloudBeacon
//
//  Created by PETRUS VAN DE PUT on 12/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//


import UIKit

/**


The KNImageProcessor class provides two methods of interaction
1. through an instance, wrapping an single image
let resizedImage = KNImageProcessor.resize(myImage, size: CGSize(width: 100, height: 150))


2. through the static functions, providing an image

let resizedAndMaskedImage = KNImageProcessor(withImage: myImage).resize(CGSize(width: 100, height: 150)).maskWithEllipse().image

let clippedImage = KNImageProcessor(withImage: myImage).resize(CGSize(width: 100, height: 150)).resizeByClipping().image


*/
public class KNImageProcessor : NSObject {
    
    public var image : UIImage
    
    public init(image withImage: UIImage) {
        self.image = withImage
    }
    
    // MARK: - Resize
    
    public func resize(size: CGSize, fitMode: KNImageProcessor.Resize.FitMode = .Clip) -> KNImageProcessor {
        self.image = KNImageProcessor.Resize.resizeImage(self.image, size: size, fitMode: fitMode)
        return self
    }
    
    @objc
    public func resizeByClipping(size: CGSize) -> KNImageProcessor {
        self.image = KNImageProcessor.Resize.resizeImage(self.image, size: size, fitMode: .Clip)
        return self
    }
    
    @objc
    public func resizeByCropping(size: CGSize) -> KNImageProcessor {
        self.image = KNImageProcessor.Resize.resizeImage(self.image, size: size, fitMode: .Crop)
        return self
    }
    
    @objc
    public func resizeByScaling(size: CGSize) -> KNImageProcessor {
        self.image = KNImageProcessor.Resize.resizeImage(self.image, size: size, fitMode: .Scale)
        return self
    }
    
    
    public struct Resize {
        public enum FitMode {
            case Clip
            case Crop
            case Scale
        }
        public static func resizeImage(image: UIImage, size: CGSize, fitMode: FitMode = .Clip) -> UIImage {
            
            let imgRef = Util.CGImageWithCorrectOrientation(image)
            let originalWidth  = CGFloat(CGImageGetWidth(imgRef))
            let originalHeight = CGFloat(CGImageGetHeight(imgRef))
            let widthRatio = size.width / originalWidth
            let heightRatio = size.height / originalHeight
            
            let scaleRatio = widthRatio > heightRatio ? widthRatio : heightRatio
            
            let resizedImageBounds = CGRect(x: 0, y: 0, width: round(originalWidth * scaleRatio), height: round(originalHeight * scaleRatio))
            let resizedImage = Util.drawImageInBounds(image, bounds: resizedImageBounds)
            
            switch (fitMode) {
            case .Clip:
                return resizedImage
            case .Crop:
                let croppedRect = CGRect(x: (resizedImage.size.width - size.width) / 2,
                    y: (resizedImage.size.height - size.height) / 2,
                    width: size.width, height: size.height)
                return Util.croppedImageWithRect(resizedImage, rect: croppedRect)
            case .Scale:
                return Util.drawImageInBounds(resizedImage, bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
        }
    }
    
    public func maskWithImage(#maskImage : UIImage)  -> KNImageProcessor {
        self.image = KNImageProcessor.Mask.maskImageWithImage(self.image, maskImage: maskImage)
        return self
    }
    
    public func maskWithEllipse(borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.whiteColor()) -> KNImageProcessor {
        self.image = KNImageProcessor.Mask.maskImageWithEllipse(self.image, borderWidth: borderWidth, borderColor: borderColor)
        return self
    }
    
    public func maskWithRoundedRect(#cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.whiteColor()) -> KNImageProcessor {
        self.image = KNImageProcessor.Mask.maskImageWithRoundedRect(self.image, cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
        return self
    }
    
    /**
    Container struct for all things Mask related
    */
    public struct Mask {
        public static func maskImageWithImage(image: UIImage, maskImage: UIImage) -> UIImage {
            
            let imgRef = Util.CGImageWithCorrectOrientation(image)
            let maskRef = maskImage.CGImage
            
            let mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                CGImageGetHeight(maskRef),
                CGImageGetBitsPerComponent(maskRef),
                CGImageGetBitsPerPixel(maskRef),
                CGImageGetBytesPerRow(maskRef),
                CGImageGetDataProvider(maskRef), nil, false);
            
            let masked = CGImageCreateWithMask(imgRef, mask);
            
            return Util.drawImageWithClosure(size: image.size) { (size: CGSize, context: CGContext) -> () in
                
                // need to flip the transform matrix, CoreGraphics has (0,0) in lower left when drawing image
                CGContextScaleCTM(context, 1, -1)
                CGContextTranslateCTM(context, 0, -size.height)
                
                CGContextDrawImage(context, CGRect(x: 0, y: 0, width: size.width, height: size.height), masked);
            }
        }
        
        public static func maskImageWithEllipse(image: UIImage,
            borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.whiteColor()) -> UIImage {
                
                let imgRef = Util.CGImageWithCorrectOrientation(image)
                let size = CGSize(width: CGFloat(CGImageGetWidth(imgRef)) / image.scale, height: CGFloat(CGImageGetHeight(imgRef)) / image.scale)
                
                return Util.drawImageWithClosure(size: size) { (size: CGSize, context: CGContext) -> () in
                    
                    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    
                    CGContextAddEllipseInRect(context, rect)
                    CGContextClip(context)
                    image.drawInRect(rect)
                    
                    if (borderWidth > 0) {
                        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
                        CGContextSetLineCap(context, kCGLineCapButt);
                        CGContextSetLineWidth(context, borderWidth);
                        CGContextAddEllipseInRect(context, CGRect(x: borderWidth / 2,
                            y: borderWidth / 2,
                            width: size.width - borderWidth,
                            height: size.height - borderWidth));
                        CGContextStrokePath(context);
                    }
                }
        }
        
        public static func maskImageWithRoundedRect(image: UIImage, cornerRadius: CGFloat,
            borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.whiteColor()) -> UIImage {
                
                let imgRef = Util.CGImageWithCorrectOrientation(image)
                let size = CGSize(width: CGFloat(CGImageGetWidth(imgRef)) / image.scale, height: CGFloat(CGImageGetHeight(imgRef)) / image.scale)
                
                return Util.drawImageWithClosure(size: size) { (size: CGSize, context: CGContext) -> () in
                    
                    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    
                    UIBezierPath(roundedRect:rect, cornerRadius: cornerRadius).addClip()
                    image.drawInRect(rect)
                    
                    if (borderWidth > 0) {
                        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
                        CGContextSetLineCap(context, kCGLineCapButt);
                        CGContextSetLineWidth(context, borderWidth);
                        
                        let borderRect = CGRect(x: 0, y: 0,
                            width: size.width, height: size.height)
                        
                        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius)
                        borderPath.lineWidth = borderWidth * 2
                        borderPath.stroke()
                    }
                }
        }
    }
    
    // MARK: - Layer
    public func layerWithOverlayImage(overlayImage: UIImage, overlayFrame: CGRect) -> KNImageProcessor {
        self.image = KNImageProcessor.Layer.overlayImage(self.image, overlayImage:overlayImage, overlayFrame:overlayFrame)
        return self
    }
    
    public struct Layer {
        
        public static func overlayImage(image: UIImage, overlayImage: UIImage, overlayFrame: CGRect) -> UIImage {
            
            let imgRef = Util.CGImageWithCorrectOrientation(image)
            let overlayRef = Util.CGImageWithCorrectOrientation(overlayImage)
            let size = CGSize(width: CGFloat(CGImageGetWidth(imgRef)) / image.scale, height: CGFloat(CGImageGetHeight(imgRef)) / image.scale)
            
            return Util.drawImageWithClosure(size: size) { (size: CGSize, context: CGContext) -> () in
                
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                image.drawInRect(rect)
                overlayImage.drawInRect(overlayFrame);
            }
        }
    }
    
    internal struct Util {
        
        static func CGImageWithCorrectOrientation(image : UIImage) -> CGImageRef {
            
            if (image.imageOrientation == UIImageOrientation.Up) {
                return image.CGImage
            }
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
            
            let context = UIGraphicsGetCurrentContext()
            switch (image.imageOrientation) {
            case UIImageOrientation.Right:
                CGContextRotateCTM(context, CGFloat(90 * M_PI/180))
                break
            case UIImageOrientation.Left:
                CGContextRotateCTM(context, CGFloat(-90 * M_PI/180))
                break
            case UIImageOrientation.Down:
                CGContextRotateCTM(context, CGFloat(M_PI))
                break
            default:
                break
            }
            
            image.drawAtPoint(CGPointMake(0, 0));
            
            let cgImage = CGBitmapContextCreateImage(context);
            UIGraphicsEndImageContext();
            
            return cgImage;
        }
        
        static func drawImageInBounds(image: UIImage, bounds : CGRect) -> UIImage {
            return drawImageWithClosure(size: bounds.size) { (size: CGSize, context: CGContext) -> () in
                image.drawInRect(bounds)
            };
        }
        
        static func croppedImageWithRect(image: UIImage, rect: CGRect) -> UIImage {
            return drawImageWithClosure(size: rect.size) { (size: CGSize, context: CGContext) -> () in
                let drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height)
                CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height))
                image.drawInRect(drawRect)
            };
        }
        
        static func drawImageWithClosure(#size: CGSize!, closure: (size: CGSize, context: CGContext) -> ()) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            closure(size: size, context: UIGraphicsGetCurrentContext())
            let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}
