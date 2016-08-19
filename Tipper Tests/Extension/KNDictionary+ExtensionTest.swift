//
//  KNDictionary+ExtensionTest.swift
//  Tipper
//
//  Created by Jay N on 12/26/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import XCTest

class KNDictionary_ExtensionTest: XCTestCase {

    func testAppend() {
        let dictionary1 = ["A": 1, "B": 2, "C": 3]
        var dictionary2 = ["A": 1]
        let dictionary3 = ["B": 2, "C": 3]
        dictionary2.append(dictionary3)
        
        XCTAssertEqual(dictionary1, dictionary2)
    }

}
