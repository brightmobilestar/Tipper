//
//  KNWithdrawCheckButton.swift
//  Tipper
//
//  Created by Gregory Walters on 1/15/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNWithdrawCheckButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    
    
    override var highlighted: Bool {
        didSet {
            
            if (highlighted) {
                self.imageView!.alpha = 0.2
            }
            else {
                self.imageView!.alpha = 1.0
            }
            
        }
    }

}
