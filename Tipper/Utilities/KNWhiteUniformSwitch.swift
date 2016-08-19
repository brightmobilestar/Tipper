//
//  KNWhiteUniformSwitch.swift
//  Tipper
//
//  Created by Gregory Walters on 2/9/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit

class KNWhiteUniformSwitch: UISwitch {

    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = self.frame.height/2.0
        self.tintColor = UIColor.clearColor()
        self.onTintColor = UIColor.clearColor()
        return super.awakeAfterUsingCoder(aDecoder)
    }

}
