//
//  ByteExtensions.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

extension UInt8 : Deserialized {
    
    public static func fromString(data:String) -> UInt8? {
        if let intVal = data.toInt() {
            if intVal > 255 {
                return Byte(255)
            } else if intVal < 0 {
                return Byte(0)
            } else {
                return Byte(intVal)
            }
        } else {
            return nil
        }
    }

    public static func deserialize(data:NSData) -> UInt8 {
        var value : Byte = 0
        if data.length >= sizeof(UInt8) {
            data.getBytes(&value, length:sizeof(Byte))
        }
        return value
    }
    
    public static func deserialize(data:NSData, start:Int) -> UInt8 {
        var value : Byte = 0
        if data.length >= start + sizeof(UInt8) {
            data.getBytes(&value, range: NSMakeRange(start, sizeof(UInt8)))
        }
        return value
    }
    
    public static func deserializeFromLittleEndian(data:NSData) -> UInt8 {
        return deserialize(data)
    }
    
    public static func deserializeArrayFromLittleEndian(data:NSData) -> [UInt8] {
        let count = data.length / sizeof(Byte)
        return [Int](0..<count).map{self.deserializeFromLittleEndian(data, start:$0)}
    }
    
    public static func deserializeFromLittleEndian(data:NSData, start:Int) -> UInt8 {
        return deserialize(data, start:start)
    }
    
    public static func deserializeFromBigEndian(data:NSData) -> UInt8 {
        return deserialize(data)
    }
    
    public static func deserializeArrayFromBigEndian(data:NSData) -> [UInt8] {
        let count = data.length / sizeof(Byte)
        return [Int](0..<count).map{self.deserializeFromBigEndian(data, start:$0)}
    }
    
    public static func deserializeFromBigEndian(data:NSData, start:Int) -> UInt8 {
        return deserialize(data, start:start)
    }

}
