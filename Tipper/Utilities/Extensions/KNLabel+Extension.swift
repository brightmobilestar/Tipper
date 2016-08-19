//
//  KNLabel+Extension.swift
//  Tipper
//
//  Created by Gregory Walters on 2/2/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation

extension UILabel {
    
    func adjustedFontSize() -> CGFloat {
        
        if self.adjustsFontSizeToFitWidth == true {
            
            var currentFont: UIFont = self.font
            let originalFontSize = currentFont.pointSize
            var currentSize: CGSize = (self.text! as NSString).sizeWithAttributes([NSFontAttributeName: currentFont])
            
            while currentSize.width > self.frame.size.width && currentFont.pointSize > (originalFontSize * self.minimumScaleFactor) {
                currentFont = currentFont.fontWithSize(currentFont.pointSize - 1)
                currentSize = (self.text! as NSString).sizeWithAttributes([NSFontAttributeName: currentFont])
            }
            
            return currentFont.pointSize
            
        }
        else {
            
            return self.font.pointSize
            
        }
        
    }
    
}
