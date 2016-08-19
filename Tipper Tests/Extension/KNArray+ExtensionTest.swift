//
//  KNArray+ExtensionTest.swift
//  Tipper
//
//  Created by Jay N on 12/26/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import XCTest

class KNArray_ExtensionTest: XCTestCase {

    var array: [Int] = []
    var stringArray: [String] = []
    
    override func setUp() {
        super.setUp()
        
        array = [1, 2, 3, 4, 5]
        stringArray = ["I", "love", "You"]
        
    }

    func testContains() {
        XCTAssertFalse(array.contains("A"))
        XCTAssertFalse(array.contains(6))
        XCTAssertFalse(array.contains(-99))
        
        XCTAssertTrue(array.contains(5))
        XCTAssertTrue(array.contains(1))
        
        XCTAssertFalse(stringArray.contains("So"))
        XCTAssertFalse(stringArray.contains(123))

        XCTAssertTrue(stringArray.contains("love"))
        XCTAssertTrue(stringArray.contains("You"))
    }
}
