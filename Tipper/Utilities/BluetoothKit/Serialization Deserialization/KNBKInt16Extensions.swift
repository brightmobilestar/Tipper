//
//  Int16Extensions.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

extension Int16 : Deserialized {
    
    public static func fromString(data:String) -> Int16? {
        if let intVal = data.toInt() {
            if intVal > 32767 {
                return Int16(32767)
            } else if intVal < -32768 {
                return Int16(-32768)
            } else {
                return Int16(intVal)
            }
        } else {
            return nil
        }
    }

    public static func deserialize(data:NSData) -> Int16 {
        var value : Int16 = 0
        if data.length >= sizeof(Int16) {
            data.getBytes(&value, length:sizeof(Int16))
        }
        return value
    }
    
    public static func deserialize(data:NSData, start:Int) -> Int16 {
        var value : Int16 = 0
        if data.length >= (sizeof(Int16) + start)  {
            data.getBytes(&value, range: NSMakeRange(start, sizeof(Int16)))
        }
        return value
    }
    
    public static func deserializeFromLittleEndian(data:NSData) -> Int16 {
        var value : Int16 = 0
        if data.length >= sizeof(Int16) {
            data.getBytes(&value , length:sizeof(Int16))
        }
        return littleEndianToHost(value)
    }
    
    public static func deserializeArrayFromLittleEndian(data:NSData) -> [Int16] {
        let size = sizeof(Int16)
        let count = data.length/size
        return [Int](0..<count).map{self.deserializeFromLittleEndian(data, start:$0*size)}
    }
    
    public static func deserializeFromLittleEndian(data:NSData, start:Int) -> Int16 {
        var value : Int16 = 0
        if data.length >= (sizeof(Int16) + start)  {
            data.getBytes(&value, range:NSMakeRange(start, sizeof(Int16)))
        }
        return littleEndianToHost(value)
    }
    
    public static func deserializeFromBigEndian(data:NSData) -> Int16 {
        var value : Int16 = 0
        if data.length >= sizeof(Int16) {
            data.getBytes(&value, length:sizeof(Int16))
        }
        return bigEndianToHost(value)
    }
    
    public static func deserializeArrayFromBigEndian(data:NSData) -> [Int16] {
        let size = sizeof(Int16)
        let count = data.length/size
        return [Int](0..<count).map{self.deserializeFromBigEndian(data, start:$0*size)}
    }
    
    public static func deserializeFromBigEndian(data:NSData, start:Int) -> Int16 {
        var value : Int16 = 0
        if data.length >= (sizeof(Int16) + start)  {
            data.getBytes(&value, range:NSMakeRange(start, sizeof(Int16)))
        }
        return bigEndianToHost(value)
    }

}
