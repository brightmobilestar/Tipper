//
//  KNLeftImageCenterTitleButton.swift
//  Tipper
//
//  Created by Jianying Shi on 1/9/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation

class KNLeftImageCenterTextButton:UIButton{
    
    var leftMargin:CGFloat = 15.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: self.bounds.width/2 - self.titleLabel!.bounds.width/2-self.imageView!.bounds.width/2-leftMargin, bottom:0, right:0)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: 0)
    }
}