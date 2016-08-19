//
//  KNCryptoMD5.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 19/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

func arrayOfBytes<T>(value:T, length:Int? = nil) -> [Byte] {
    let totalBytes = length ?? (sizeofValue(value) * 8)
    var v = value
    var valuePointer = UnsafeMutablePointer<T>.alloc(1)
    valuePointer.memory = value
    var bytesPointer = UnsafeMutablePointer<Byte>(valuePointer)
    var bytes = [Byte](count: totalBytes, repeatedValue: 0)
    for j in 0..<min(sizeof(T),totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).memory
    }
    valuePointer.destroy()
    valuePointer.dealloc(1)
    return bytes
}

extension Int {
    
    public func bytes(_ totalBytes: Int = sizeof(Int)) -> [Byte] {
        return arrayOfBytes(self, length: totalBytes)
    }
}

extension NSMutableData {
    internal func appendBytes(arrayOfBytes: [Byte]) {
        self.appendBytes(arrayOfBytes, length: arrayOfBytes.count)
    }
    
}

class HashBase {
    var message: NSData
    init(_ message: NSData) {
        self.message = message
    }

    func prepare(_ len:Int = 64) -> NSMutableData {
        var tmpMessage: NSMutableData = NSMutableData(data: self.message)
        tmpMessage.appendBytes([0x80])
        while tmpMessage.length % len != (len - 8) {
            tmpMessage.appendBytes([0x00])
        }
        return tmpMessage
    }
}

func rotateLeft(v:UInt32, n:UInt32) -> UInt32 {
    return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
}

class MD5 : HashBase {
    private let s: [UInt32] = [7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
        5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
        4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
        6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21]
    
    private let k: [UInt32] = [0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,
        0xf57c0faf,0x4787c62a,0xa8304613,0xfd469501,
        0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,
        0x6b901122,0xfd987193,0xa679438e,0x49b40821,
        0xf61e2562,0xc040b340,0x265e5a51,0xe9b6c7aa,
        0xd62f105d,0x2441453,0xd8a1e681,0xe7d3fbc8,
        0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,
        0xa9e3e905,0xfcefa3f8,0x676f02d9,0x8d2a4c8a,
        0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,
        0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,
        0x289b7ec6,0xeaa127fa,0xd4ef3085,0x4881d05,
        0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,
        0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,
        0x655b59c3,0x8f0ccc92,0xffeff47d,0x85845dd1,
        0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,
        0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391]
    
    private let h:[UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
    
    func calculate() -> NSData {
        var tmpMessage = prepare()
        var hh = h
        var lengthInBits = (message.length * 8)
        var lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage.appendBytes(reverse(lengthBytes))
        let chunkSizeBytes = 512 / 8 // 64
        var leftMessageBytes = tmpMessage.length
        for var i = 0; i < tmpMessage.length; i = i + chunkSizeBytes, leftMessageBytes -= chunkSizeBytes {
            let chunk = tmpMessage.subdataWithRange(NSRange(location: i, length: min(chunkSizeBytes,leftMessageBytes)))

            var M:[UInt32] = [UInt32](count: 16, repeatedValue: 0)
            var t: UInt32 = 0
            for x in 0..<M.count {
                
                chunk.getBytes(&t, range:NSRange(location:x * sizeofValue(UInt32), length: sizeofValue(UInt32)))
                M[x] = t
            }

            var A:UInt32 = hh[0]
            var B:UInt32 = hh[1]
            var C:UInt32 = hh[2]
            var D:UInt32 = hh[3]
            
            var dTemp:UInt32 = 0

            for j in 0..<k.count {
                var g = 0
                var F:UInt32 = 0
                
                switch (j) {
                case 0...15:
                    F = (B & C) | ((~B) & D)
                    g = j
                    break
                case 16...31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                    break
                case 32...47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                    break
                case 48...63:
                    F = C ^ (B | (~D))
                    g = (7 * j) % 16
                    break
                default:
                    break
                }
                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft((A &+ F &+ k[j] &+ M[g]), s[j])
                A = dTemp
            }
            
            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }
        
        var buf: NSMutableData = NSMutableData()
        hh.map({ (item) -> () in
            var i:UInt32 = item.littleEndian
            buf.appendBytes(&i, length: sizeofValue(i))
        })
        
        return buf.copy() as NSData
    }
}
