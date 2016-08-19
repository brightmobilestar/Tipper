//
//  KNBKDeserializedCharacteristicProfile.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public class KNBKDeserializedCharacteristicProfile<DeserializedType:Deserialized where DeserializedType == DeserializedType.SelfType> : KNBKCharacteristicProfile {

    // PUBLIC
    public var endianness : Endianness = .Little

    public override init(uuid:String, name:String, initializer:((characteristicProfile:KNBKDeserializedCharacteristicProfile<DeserializedType>) -> ())? = nil) {
        super.init(uuid:uuid, name:name)
        if let runInitializer = initializer {
            runInitializer(characteristicProfile:self)
        }
    }

    public override func anyValue(data:NSData) -> Any? {
        let deserializedValue = self.deserialize(data)
        KNBKLogger.debug("KNBKDeserializedCharacteristicProfile#anyValue: data = \(data.hexStringValue()), value = \(deserializedValue)")
        return deserializedValue
    }
    
    public override func dataFromStringValue(data:Dictionary<String, String>) -> NSData? {
        if let stringValue = data[self.name] {
            if let value = DeserializedType.fromString(stringValue) {
                KNBKLogger.debug("KNBKDeserializedCharacteristicProfile#dataValue: data = \(data), value = \(value)")
                return self.serialize(value)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public override func dataFromAnyValue(object:Any) -> NSData? {
        if let value = object as? DeserializedType {
            KNBKLogger.debug("KNBKDeserializedCharacteristicProfile#dataValue: value = \(value)")
            return self.serialize(value)
        } else {
            return nil
        }
    }
    
    // INTERNAL
    public override func stringValues(data:NSData) -> Dictionary<String, String>? {
        if let value = self.anyValue(data) as? DeserializedType {
            return [self.name:"\(value)"]
        } else {
            return nil
        }
    }
    
    // PRIVATE
    private func deserialize(data:NSData) -> DeserializedType {
        switch self.endianness {
        case Endianness.Little:
            return DeserializedType.deserializeFromLittleEndian(data)
        case Endianness.Big:
            return DeserializedType.deserializeFromBigEndian(data)
        }
    }
    
    private func serialize(value:DeserializedType) -> NSData {
        switch self.endianness {
        case Endianness.Little:
            return NSData.serializeToLittleEndian(value)
        case Endianness.Big:
            return NSData.serializeToBigEndian(value)
        }
    }
    
}