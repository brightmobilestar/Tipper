//
//  KNTutorialViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit
class KNTutorialViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNTutorialViewController() {
        
        var storyboard: UIStoryboard = UIStoryboard(name: kTutorialStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let vc = storyboard.instantiateViewControllerWithIdentifier(kTutorialMasterPage) as KNTutorialViewController
        
        XCTAssertNotNil(vc, "Can not find KNTutorialViewController")
        vc.loadView()

        let nextActions = vc.nextButton!.actionsForTarget(vc, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(nextActions, "nextButton not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(nextActions!.first!.isEqualToString("nextPage"), "nextButton not hooked to nextPage")
        
        let prevActions = vc.prevButton!.actionsForTarget(vc, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(prevActions, "prevButton not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(prevActions!.first!.isEqualToString("prevPage"), "prevButton not hooked to prevPage")
        
        let closeActions = vc.closeButton!.actionsForTarget(vc, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(closeActions, "closeButton not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(closeActions!.first!.isEqualToString("close:"), "closeButton not hooked to close")
    }

}
