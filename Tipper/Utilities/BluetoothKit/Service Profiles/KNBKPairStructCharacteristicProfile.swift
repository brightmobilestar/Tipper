//
//  KNBKPairStructCharacteristicProfile.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public class KNBKPairStructCharacteristicProfile<StructType:DeserializedPairStruct where StructType.RawType1 == StructType.RawType1.SelfType,
                                                                                     StructType.RawType2 == StructType.RawType2.SelfType,
                                                                                     StructType == StructType.SelfType> : KNBKCharacteristicProfile {
    
    // PUBLIC
    public var endianness : Endianness = .Little

    public override init(uuid:String, name:String, initializer:((characteristicProfile:KNBKPairStructCharacteristicProfile<StructType>) -> ())? = nil) {
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
        let (raw1Size, raw2Size) = StructType.rawValueSizes()
        if raw1Size+raw2Size == data.length {
            let rawData1 = data.subdataWithRange(NSMakeRange(0, raw1Size))
            let rawData2 = data.subdataWithRange(NSMakeRange(raw1Size, raw2Size))
            let values = self.deserialize(rawData1, raw2Data: rawData2)
            if let value = StructType.fromRawValues(values) {
                KNBKLogger.debug("KNBKStructCharacteristicProfile#anyValue: data = \(data.hexStringValue()), value = \(value.toRawValues())")
                return value
            } else {
                return nil
            }
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
    private func deserialize(raw1Data:NSData, raw2Data:NSData) -> ([StructType.RawType1], [StructType.RawType2]) {
        switch self.endianness {
        case Endianness.Little:
            return (StructType.RawType1.deserializeArrayFromLittleEndian(raw1Data), StructType.RawType2.deserializeArrayFromLittleEndian(raw2Data))
        case Endianness.Big:
            return (StructType.RawType1.deserializeArrayFromBigEndian(raw1Data), StructType.RawType2.deserializeArrayFromBigEndian(raw2Data))
        }
    }
    
    private func serialize(rawValues:([StructType.RawType1], [StructType.RawType2])) -> NSData {
        switch self.endianness {
        case Endianness.Little:
            return NSData.serializeArrayPairToLittleEndian(rawValues)
        case Endianness.Big:
            return NSData.serializeArrayPairToBigEndian(rawValues)
        }
    }
    
}
