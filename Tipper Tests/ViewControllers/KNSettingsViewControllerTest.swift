//
//  KNSettingsViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit

class KNSettingsViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKNSettingsViewController() {
        var storyboard:UIStoryboard = UIStoryboard(name: kSettingStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let vc = storyboard.instantiateViewControllerWithIdentifier("KNSettingsViewController") as KNSettingsViewController

        XCTAssertNotNil(vc, "Can not find KNSettingsViewController instance")
        vc.loadView()
        
        let backAction = NSStringFromSelector(vc.backButton!.action)
        XCTAssertTrue(backAction == "closeViewPressed:", "backButton not hooked to closeViewPressed:")
    }

}
