//
//  KNBeaconManager.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 10/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
class KNBeaconManager {
    
    class var sharedInstance : KNBeaconManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNBeaconManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNBeaconManager()
        }
        return Static.instance!
    }
    
    init() {
        
    }
    
    
    
}

