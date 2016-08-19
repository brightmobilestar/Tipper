//
//  KNPasscodeViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit

class KNPasscodeViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNPasscodeViewController() {
        var storyboard: UIStoryboard = UIStoryboard(name: kPasscodeStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let viewcontroller = storyboard.instantiateViewControllerWithIdentifier(kPasscodeStoryboardId) as? KNPasscodeViewController
        viewcontroller?.loadView()
        XCTAssertNotNil(viewcontroller?, "Get KNPasscodeViewController successfully")
        let closeAction = viewcontroller?.btnClose?.actionsForTarget(viewcontroller!, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(closeAction, "Close button connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(closeAction!.first!.isEqualToString("clickCloseButton:"), "Close button hooked to close action")
    }
    
}
