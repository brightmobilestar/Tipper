//
//  KNBLEDefinitions.swift
//  BLETransmitter
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2015 Knodeit. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

let kBLEUserInfoServiceUUID                     : CBUUID            = CBUUID(string:"5678")
let kBLEUserInfoServiceName                     : String            = "User Info"

let kBLEUserStringDataCharacteristicUUID        : CBUUID            = CBUUID(string:"3324")
let kBLEUserStringDataCharacteristicName        : String            = "User StringData"

let kBLEUserDictionaryDataCharacteristicUUID    : CBUUID            = CBUUID(string:"2224")
let kBLEUserDictionaryDataCharacteristicName    : String            = "User Dictionary Data"


let kBLEConnectCapacity                         : Int               = 10

let kBLEScanTimeoutEnabled                      : Bool              = true
let kBLEScanTimeout                             : Double            = 10.0
let kBLEPeripheralConnectTimeout                : Double            = 10.0
let kBLECharacterisiticReadWriteTimeout         : Double            = 10.0
let kBLEMaximumReconnects                       : Int               = 5
