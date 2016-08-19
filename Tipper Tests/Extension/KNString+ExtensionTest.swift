//
//  KNString+ExtensionTest.swift
//  Tipper
//
//  Created by Jay N on 12/26/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import XCTest

class KNString_ExtensionTest: XCTestCase {

    func testLength() {
        XCTAssertEqual(0, "".length)
        XCTAssertEqual(1, "A".length)
        XCTAssertEqual(1, "😱".length)
        XCTAssertEqual(1, "∞".length)
        XCTAssertEqual(3, "∞aA".length)
        XCTAssertEqual(7, "a@&1.}$".length)
    }
    
    func testUppercase() {
        XCTAssertEqual("", "".uppercase)
        XCTAssertEqual("A", "a".uppercase)
        XCTAssertEqual("!@1AB😗.∆", "!@1Ab😗.∆".uppercase)
    }
    
    func testLowercase() {
        XCTAssertEqual("", "".lowercase)
        XCTAssertEqual("abc", "ABC".lowercase)
        XCTAssertEqual("!@1ab😗.∆", "!@1Ab😗.∆".lowercase)
    }
    
    func testSubscript() {
        let string = "∆Test😗"
        
        XCTAssertEqual("∆", string[0])
        XCTAssertEqual("T", string[1])
        XCTAssertEqual("😗", string[string.length - 1])
        XCTAssertEqual("", string[string.length])
        XCTAssertEqual("", string[-1])
        XCTAssertEqual("", string[999])
        XCTAssertEqual("h", "hello"[0])
        
        XCTAssertEqual("Test😗", string[1..<6])
        XCTAssertEqual("", string[-1..<6])
        XCTAssertEqual("", string[0..<100])
        XCTAssertEqual("", string[-100..<100])
    }

}
