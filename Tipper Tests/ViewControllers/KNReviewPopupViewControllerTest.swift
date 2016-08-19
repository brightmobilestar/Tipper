//
//  KNReviewPopupViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit
class KNReviewPopupViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNReviewPopupViewController() {
        
        var storyboard: UIStoryboard = UIStoryboard(name: kReviewStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let vc = storyboard.instantiateViewControllerWithIdentifier(kReviewControllerName) as KNReviewPopupViewController

        XCTAssertNotNil(vc, "Can not find KNReviewPopupViewController")
        vc.loadView()
        
        let yesActions = vc.ofCourseButton!.actionsForTarget(vc, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(yesActions, "ofCourseButton not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(yesActions!.first!.isEqualToString("yesButtonTap:"), "ofCourseButton not hooked to yesButtonTap")
        
        let noActions = vc.noThanksButton!.actionsForTarget(vc, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(noActions, "noThanksButton not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(noActions!.first!.isEqualToString("noButtonTap:"), "noThanksButton not hooked to yesButtonTap")
        
        let maybeActions = vc.maybeButton!.actionsForTarget(vc, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(maybeActions, "maybeButton not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(maybeActions!.first!.isEqualToString("maybeButtonTap:"), "maybeButton not hooked to maybeButtonTap")
    }

}
