//
//  KNMobileNumberViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit
class KNMobileNumberViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNMobileNumberViewController() {
        
        var storyboard: UIStoryboard = UIStoryboard(name: kAccountStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let vc = storyboard.instantiateViewControllerWithIdentifier("KNMobileNumberViewController") as KNMobileNumberViewController
        
        XCTAssertNotNil(vc, "Can not find KNMobileNumberViewController")
        vc.loadView()
        
        let backAction = NSStringFromSelector(vc.backButton!.action)
        XCTAssertTrue(backAction == "goBack:", "backButton not hooked to goBack:")
        
        let nextAction = NSStringFromSelector(vc.nextButton!.action)
        XCTAssertTrue(nextAction == "goToNext:", "nextButton not hooked to goToNext:")
        
        let doneEditAction = NSStringFromSelector(vc.doneEditButton!.action)
        XCTAssertTrue(doneEditAction == "doneEdit:", "doneEditButton not hooked to doneEdit:")
        
        let flagButtonActions = vc.flagButton!.actionsForTarget(vc, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(flagButtonActions, "flagButton not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(flagButtonActions!.first!.isEqualToString("showCountries"), "flagButton not hooked to showCountries")
        
        let moreButtonActions = vc.moreButton!.actionsForTarget(vc, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(moreButtonActions, "moreButton not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(moreButtonActions!.first!.isEqualToString("showCountries"), "moreButton not hooked to showCountries")
    }
    
}
