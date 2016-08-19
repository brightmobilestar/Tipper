//
//  KNBKStructCharacteristicProfile.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public class KNBKStructCharacteristicProfile<StructType:DeserializedStruct where StructType.RawType == StructType.RawType.SelfType, StructType == StructType.SelfType> : KNBKCharacteristicProfile {
    
    // PUBLIC
    public var endianness : Endianness = .Little

    public override init(uuid:String, name:String, initializer:((characteristicProfile:KNBKStructCharacteristicProfile<StructType>) -> ())? = nil) {
        super.init(uuid:uuid, name:name)
        if let runInitializer = initializer {
            runInitializer(characteristicProfile:self)
        }
    }

    public override func stringValues(data:NSData) -> Dictionary<String, String>? {
        if let value = self.anyValue(data) as? StructType {
            return value.stringValues
        } else {
            return nil
        }
    }
    
    public override func anyValue(data:NSData) -> Any? {
        let values = self.deserialize(data)
        if let value = StructType.fromRawValues(values) {
            KNBKLogger.debug("KNBKStructCharacteristicProfile#anyValue: data = \(data.hexStringValue()), value = \(value.toRawValues())")
            return value
        } else {
            return nil
        }
    }
    
    public override func dataFromStringValue(data:Dictionary<String, String>) -> NSData? {
        if let value = StructType.fromStrings(data) {
            KNBKLogger.debug("KNBKStructCharacteristicProfile#dataValue: data = \(data), value = \(value.toRawValues())")
            return self.serialize(value.toRawValues())
        } else {
            return nil
        }
    }
    
    public override func dataFromAnyValue(object:Any) -> NSData? {
        if let value = object as? StructType {
            KNBKLogger.debug("KNBKStructCharacteristicProfile#dataValue: value = \(value.toRawValues())")
            return self.serialize(value.toRawValues())
        } else {
            return nil
        }
    }
    
    // PRIVATE
    private func deserialize(data:NSData) -> [StructType.RawType] {
        switch self.endianness {
        case Endianness.Little:
            return StructType.RawType.deserializeArrayFromLittleEndian(data)
        case Endianness.Big:
            return StructType.RawType.deserializeArrayFromBigEndian(data)
        }
    }
    
    private func serialize(values:[StructType.RawType]) -> NSData {
        switch self.endianness {
        case Endianness.Little:
            return NSData.serializeArrayToLittleEndian(values)
        case Endianness.Big:
            return NSData.serializeArrayToBigEndian(values)
        }
    }
    
}
