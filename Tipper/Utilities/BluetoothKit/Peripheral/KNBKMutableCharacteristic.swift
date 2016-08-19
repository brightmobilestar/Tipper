//
//  KNBKMutableCharacteristic.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation
import CoreBluetooth

public class KNBKMutableCharacteristic : NSObject {
    
    private let profile                         : KNBKCharacteristicProfile!
    private var _value                          : NSData!
    
    internal let cbMutableChracteristic         : CBMutableCharacteristic!
    internal var processWriteRequestPromise     : KNBKStreamPromise<CBATTRequest>?
    
    public var permissions : CBAttributePermissions {
        return self.cbMutableChracteristic.permissions
    }
    
    public var properties : CBCharacteristicProperties {
        return self.cbMutableChracteristic.properties
    }
    
    public var uuid : CBUUID {
        return self.profile.uuid
    }
    
    public var name : String {
        return self.profile.name
    }
    
    public var value : NSData! {
        get {
            return self._value
        }
        set {
            self._value = newValue
        }
    }
    
    public var stringValues : Dictionary<String, String>? {
        if self.value != nil {
            return self.profile.stringValues(self.value)
        } else {
            return nil
        }
    }
    
    public var anyValue : Any? {
        if self.value != nil {
            return self.profile.anyValue(self.value)
        } else {
            return nil
        }
    }
    
    public class func withProfiles(profiles:[KNBKCharacteristicProfile]) -> [KNBKMutableCharacteristic] {
        return profiles.map{KNBKMutableCharacteristic(profile:$0)}
    }
    
    public init(profile:KNBKCharacteristicProfile) {
        super.init()
        self.profile = profile
        self._value = self.profile.initialValue
        self.cbMutableChracteristic = CBMutableCharacteristic(type:profile.uuid, properties:profile.properties, value:nil, permissions:profile.permissions)
    }
    
    public var discreteStringValues : [String] {
        return self.profile.discreteStringValues
    }
    
    public func startProcessingWriteRequests(capacity:Int? = nil) -> KNBKFutureStream<CBATTRequest> {
        if let capacity = capacity {
            self.processWriteRequestPromise = KNBKStreamPromise<CBATTRequest>(capacity:capacity)
        } else {
            self.processWriteRequestPromise = KNBKStreamPromise<CBATTRequest>()
        }
        return self.processWriteRequestPromise!.future
    }
    
    public func stopProcessingWriteRequests() {
        self.processWriteRequestPromise = nil
    }
    
    public func respondToRequest(request:CBATTRequest, withResult result:CBATTError) {
        KNBKPeripheralManager.sharedInstance.cbPeripheralManager.respondToRequest(request, withResult:result)
    }
    
    public func propertyEnabled(property:CBCharacteristicProperties) -> Bool {
        return (self.properties.rawValue & property.rawValue) > 0
    }
    
    public func permissionEnabled(permission:CBAttributePermissions) -> Bool {
        return (self.permissions.rawValue & permission.rawValue) > 0
    }
    
    public func updateValueWithData(value:NSData) {
        self._value = value
        KNBKPeripheralManager.sharedInstance.cbPeripheralManager.updateValue(value, forCharacteristic:self.cbMutableChracteristic, onSubscribedCentrals:nil)
    }
    
    public func updateValueWithString(value:Dictionary<String, String>) {
        if let data = self.profile.dataFromStringValue(value) {
            self.updateValueWithData(data)
        } else {
            NSException(name:"KNBKCharacteristic update error", reason: "invalid value '\(value)' for \(self.uuid.UUIDString)", userInfo: nil).raise()
        }
    }
    
    public func updateValue(value:Any) {
        if let data = self.profile.dataFromAnyValue(value) {
            self.updateValueWithData(data)
        } else {
            NSException(name:"KNBKCharacteristic update error", reason: "invalid value '\(value)' for \(self.uuid.UUIDString)", userInfo: nil).raise()
        }
    }
    
}