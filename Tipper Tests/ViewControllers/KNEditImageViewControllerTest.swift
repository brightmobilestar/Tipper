//
//  KNEditImageViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest

import UIKit
class KNEditImageViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNEditImageViewController() {
        var storyboard: UIStoryboard = UIStoryboard(name: kEditImageStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let viewcontroller = storyboard.instantiateViewControllerWithIdentifier(kEditImageViewControllerId) as? KNEditImageViewController
        viewcontroller?.loadView()
        XCTAssertNotNil(viewcontroller?, "Get KNEditImageViewController successfully")
        
        let retakeAction = viewcontroller?.btnRetake?.actionsForTarget(viewcontroller!, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(retakeAction, "Retake button connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(retakeAction!.first!.isEqualToString("retakeAvatarPressed:"), "Retake Button hooked to retake action")
        
        let useAction = viewcontroller?.btnUse?.actionsForTarget(viewcontroller!, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(useAction, "Use button connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(useAction!.first!.isEqualToString("useAvatarPressed:"), "Use button hooked to retake action")
    }

}
