//
//  KNValidationCodeViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit
class KNValidationCodeViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNValidationCodeViewController() {
        
        var storyboard: UIStoryboard = UIStoryboard(name: kAccountStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let vc = storyboard.instantiateViewControllerWithIdentifier("KNValidationCodeViewController") as KNValidationCodeViewController
        
        XCTAssertNotNil(vc, "Can not find KNValidationCodeViewController")
        vc.loadView()
        
        let backAction = NSStringFromSelector(vc.backButton!.action)
        XCTAssertTrue(backAction == "goBack:", "backButton not hooked to goBack:")
        
        let resendAction = NSStringFromSelector(vc.resendCodeButton!.action)
        XCTAssertTrue(resendAction == "resendCode:", "resendCodeButton not hooked to resendCode:")
    }

}
