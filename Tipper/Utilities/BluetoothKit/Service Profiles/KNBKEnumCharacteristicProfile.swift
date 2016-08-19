//
//  KNBKEnumCharacteristicProfile.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public class KNBKEnumCharacteristicProfile<EnumType:DeserializedEnum where EnumType.RawType == EnumType.RawType.SelfType, EnumType == EnumType.SelfType> : KNBKCharacteristicProfile {
    
    // PUBLIC
    public var endianness : Endianness = .Little

    public override var discreteStringValues : [String] {
        return EnumType.stringValues()
    }

    public override func stringValues(data:NSData) -> Dictionary<String, String>? {
        if let value = self.anyValue(data) as? EnumType {
            return [self.name:value.stringValue]
        } else {
            return nil
        }
    }
    
    public override func anyValue(data:NSData) -> Any? {
        let valueRaw = self.deserialize(data)
        KNBKLogger.debug("KNBKEnumCharacteristicProfile#anyValue: data = \(data.hexStringValue()), raw value = \(valueRaw)")
        if let value =  EnumType.fromRaw(valueRaw) {
            return value
        } else {
            return nil
        }
    }
    
    public override func dataFromStringValue(data:Dictionary<String, String>) -> NSData? {
        KNBKLogger.debug("KNBKEnumCharacteristicProfile#dataValueString: data = \(data)")
        if let dataString = data[self.name] {
            KNBKLogger.debug("KNBKEnumCharacteristicProfile#dataValue: data = \(data)")
            if let value = EnumType.fromString(dataString) {
                return self.serialize(value.toRaw())
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public override func dataFromAnyValue(object:Any) -> NSData? {
        if let value = object as? EnumType {
            KNBKLogger.debug("KNBKEnumCharacteristicProfile#dataValue: data = \(value.toRaw())")
            return self.serialize(value.toRaw())
        } else {
            return nil
        }
    }
    
    // INTERNAL
    internal override init(uuid:String, name:String, initializer:((characteristicProfile:KNBKEnumCharacteristicProfile<EnumType>) -> ())? = nil) {
        super.init(uuid:uuid, name:name)
        if let runInitializer = initializer {
            runInitializer(characteristicProfile:self)
        }
    }
    
    // PRIVATE
    private func deserialize(data:NSData) -> EnumType.RawType {
        switch self.endianness {
        case Endianness.Little:
            return EnumType.RawType.deserializeFromLittleEndian(data)
        case Endianness.Big:
            return EnumType.RawType.deserializeFromBigEndian(data)
        }
    }
    
    private func serialize(value:EnumType.RawType) -> NSData {
        switch self.endianness {
        case Endianness.Little:
            return NSData.serializeToLittleEndian(value)
        case Endianness.Big:
            return NSData.serializeToBigEndian(value)
        }
    }
    
}
