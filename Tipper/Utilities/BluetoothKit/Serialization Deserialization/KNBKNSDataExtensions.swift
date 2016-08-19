//
//  NSDataExtensions.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

extension NSData : Serialized {

    public class func serialize<SerializedType>(value:SerializedType) -> NSData {
        let values = [value]
        return NSData(bytes:values, length:sizeof(SerializedType))
    }
    
    public class func serializeArray<SerializedType>(values:[SerializedType]) -> NSData {
        return NSData(bytes:values, length:values.count*sizeof(SerializedType))
    }
    
    public class func serializeToLittleEndian<SerializedType>(value:SerializedType) -> NSData {
        let values = [hostToLittleEndian(value)]
        return NSData(bytes:values, length:sizeof(SerializedType))
    }
    
    public class func serializeArrayToLittleEndian<SerializedType>(values:[SerializedType]) -> NSData {
        let littleValues = values.map{hostToLittleEndian($0)}
        return NSData(bytes:littleValues, length:sizeof(SerializedType)*littleValues.count)
    }
    
    public class func serializeArrayPairToLittleEndian<SerializedType1, SerializedType2>(values:([SerializedType1], [SerializedType2])) -> NSData {
        let (values1, values2) = values
        let data = NSMutableData()
        data.setData(NSData.serializeArrayToLittleEndian(values1))
        data.appendData(NSData.serializeArrayToLittleEndian(values2))
        return data
    }

    public class func serializeToBigEndian<SerializedType>(value:SerializedType) -> NSData {
        let values = [hostToBigEndian(value)]
        return NSData(bytes:values, length:sizeof(SerializedType))
    }
    
    public class func serializeArrayToBigEndian<SerializedType>(values:[SerializedType]) -> NSData {
        let bigValues = values.map{hostToBigEndian($0)}
        return NSData(bytes:bigValues, length:sizeof(SerializedType)*bigValues.count)
    }

    public class func serializeArrayPairToBigEndian<SerializedType1, SerializedType2>(values:([SerializedType1], [SerializedType2])) -> NSData {
        let (values1, values2) = values
        let data = NSMutableData()
        data.setData(NSData.serializeArrayToBigEndian(values1))
        data.appendData(NSData.serializeArrayToBigEndian(values2))
        return data
    }

    public func hexStringValue() -> String {
        var dataBytes = Array<Byte>(count:self.length, repeatedValue:0x0)
        self.getBytes(&dataBytes, length:self.length)
        var hexString = dataBytes.reduce(""){(out:String, dataByte:Byte) in
            out +  NSString(format:"%02lx", dataByte)
        }
        return hexString
    }
    
}
