//
//  KNAccountCreateViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit
class KNAccountCreateViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNAccountCreateViewController() {
        
        var storyboard: UIStoryboard = UIStoryboard(name: kAccountStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let vc = storyboard.instantiateViewControllerWithIdentifier(kAccountCreateStoryboardId) as KNAccountCreateViewController
        
        XCTAssertNotNil(vc, "Can not find KNAccountCreateViewController")
        vc.loadView()
        
        let backAction = NSStringFromSelector(vc.btnBack!.action)
        XCTAssertTrue(backAction == "backSplashScreen:", "btnBack not hooked to backSplashScreen:")

        let createAccountAction = NSStringFromSelector(vc.btnNext!.action)
        XCTAssertTrue(createAccountAction == "goToMobileNumberController:", "btnNext not hooked to goToMobileNumberController:")
    }

}
