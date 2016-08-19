//
//  KNMessageViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit

class KNMessageViewControllerTest: XCTestCase {


    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNMessageViewController() {
        var storyboard: UIStoryboard = UIStoryboard(name: kMessageStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let viewcontroller = storyboard.instantiateInitialViewController() as? KNMessageViewController
        viewcontroller?.loadView()
        XCTAssertNotNil(viewcontroller?, "Get KNMessageViewController successfully")
    }

}
