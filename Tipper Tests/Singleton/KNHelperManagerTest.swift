//
//  KNHelperManagerTest.swift
//  CloudBeacon
//
//  Created by PETRUS VAN DE PUT on 10/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit
import XCTest

class KNHelperManagerTest: XCTestCase {
    
    let url = "http://static.iconarchive.com/static/images/ia/logo/logo.png"
    let expectedResult = "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"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSharedInstance_ThreadSafety() {
        var instance1 : KNHelperManager!
        var instance2 : KNHelperManager!
        
        let expectation1 = expectationWithDescription("Instance 1")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            instance1 = KNHelperManager.sharedInstance
            expectation1.fulfill()
        }
        let expectation2 = expectationWithDescription("Instance 2")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            instance2 = KNHelperManager.sharedInstance
            expectation2.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
            XCTAssertTrue(instance1 === instance2)
        })
        
        
    }
    
    func testIsValidNumberOfCharacter() {
        let checkOption1: Bool = KNHelperManager.sharedInstance.isValidNumberOfCharacter("Peter V", minCharacter: 2, maxCharacter: 15)
        XCTAssertTrue(checkOption1, "It should be true")
        
        let checkOption2: Bool = KNHelperManager.sharedInstance.isValidNumberOfCharacter("P", minCharacter: 2, maxCharacter: 15)
        XCTAssertFalse(checkOption2, "It should be false")
    }
    
    func testIsValidPublicName() {
        let checkOption1: Bool = KNHelperManager.sharedInstance.isValidPublicName("Peter V")
        XCTAssertTrue(checkOption1, "It should be true")
        
        let checkOption2: Bool = KNHelperManager.sharedInstance.isValidPublicName("Peter ")
        XCTAssertFalse(checkOption2, "It should be false")
    }
    
    func testIsValidEmail(){
        XCTAssertTrue(KNHelperManager.sharedInstance.isValidEmail("peter@knodeit.com"))
        XCTAssertFalse(KNHelperManager.sharedInstance.isValidEmail("peterknodeit.com"))
    }
    
    func testImageURLToBase64String(){
        let base64String = KNHelperManager.sharedInstance.imageURLToBase64String(self.url)
        let isEqual = (base64String == self.expectedResult)
        XCTAssertTrue(isEqual,"Strings are equal")
    }
    
    func testDataToBase64String() {
        let url = NSURL(string:self.url)!
        let data: NSData = NSData(contentsOfURL: url)!
        let check: String = KNHelperManager.sharedInstance.dataToBase64String(data)
        XCTAssertTrue(check == self.expectedResult, "Strings are equal")
    }
    
    func testDecodeBase64ToImage() {
        let image: UIImage = KNHelperManager.sharedInstance.decodeBase64ToImage(self.expectedResult)!
        XCTAssertNotNil(image, "It shouldn't be nil")
    }
    
    func testGetAppVersion(){
        let expectedResult = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as String
        let isEqual = (KNHelperManager.sharedInstance.getAppVersion() == expectedResult)
         XCTAssertTrue(isEqual,"Strings are equal")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
