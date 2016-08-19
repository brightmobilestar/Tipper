//
//  KNAvatarButton.swift
//  Tipper
//
//  Created by Nguyen Phuc Loc on 1/12/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNAvatarButton: UIButton {

    var imgvAvatar: UIImageView?
    let titleMarginleft:CGFloat = 5.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRectMake(0, 0, self.frame.height, self.frame.height)
        self.imgvAvatar = UIImageView(frame: self.imageView!.frame)
        self.imgvAvatar?.image = self.imageView?.image
        self.imageView?.addSubview(self.imgvAvatar!)
        self.titleLabel?.frame = CGRectMake(self.frame.height + titleMarginleft, 0, self.frame.width - (self.frame.height + titleMarginleft), self.frame.height)
        self.titleLabel?.font = UIFont.systemFontOfSize(18)
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
    }

}
