//
//  KNBKStringCharacteristicProfile.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public class KNBKStringCharacteristicProfile : KNBKCharacteristicProfile {
    
    // PUBLIC
    public var encoding : NSStringEncoding = NSUTF8StringEncoding

    public override init(uuid:String, name:String, initializer:((characteristicProfile:KNBKStringCharacteristicProfile) -> ())? = nil) {
        super.init(uuid:uuid, name:name)
        if let runInitializer = initializer {
            runInitializer(characteristicProfile:self)
        }
    }
    
    public override init(uuid:CBUUID, name:String, initializer:((characteristicProfile:KNBKStringCharacteristicProfile) -> ())? = nil) {
        super.init(uuid:uuid, name:name)
        if let runInitializer = initializer {
            runInitializer(characteristicProfile:self)
        }
    }
    
    public override func stringValues(data:NSData) -> [String:String]? {
        let value = NSString(data:data, encoding:self.encoding) as String
        return [self.name:value]
    }
    
    public override func anyValue(data:NSData) -> Any? {
        return NSString(data:data, encoding:self.encoding)
    }
    
    public override func dataFromStringValue(data:Dictionary<String, String>) -> NSData? {
        if let value = data[self.name] {
            return self.dataFromAnyValue(value)
        } else {
            return nil
        }
    }
    
    public override func dataFromAnyValue(object:Any) -> NSData? {
        if let value = object as? String {
            return value.dataUsingEncoding(self.encoding)
        } else {
            return nil
        }
    }
}
