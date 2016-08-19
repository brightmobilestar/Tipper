//
//  KNButton.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 16/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import Foundation
import UIKit


// Action Types
enum KNActionType {
    case None, Selector, Closure
}


// Button sub-class
class KNButton: UIButton {
    var actionType = KNActionType.None
    var target:AnyObject!
    var selector:Selector!
    var action:(()->Void)!
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
}