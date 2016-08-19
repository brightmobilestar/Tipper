//
//  KNImage+Extension.swift
//  Tipper
//
//  Created by Jianying Shi on 1/9/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation


extension UIImage{
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}