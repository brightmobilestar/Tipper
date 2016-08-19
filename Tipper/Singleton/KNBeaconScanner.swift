//
//  KNBeaconScanner.swift
//  Tipper
//
//  Created by PETRUS VAN DE PUT on 11/01/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreBluetooth


class KNBeaconScanner: NSObject {
    
    
    class var sharedInstance : KNBeaconScanner {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : KNBeaconScanner? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = KNBeaconScanner()
        }
        return Static.instance!
    }
    
    
    
    
}


