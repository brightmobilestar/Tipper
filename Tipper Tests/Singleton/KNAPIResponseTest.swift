//
//  KNAPIResponseTest.swift
//  CloudBeacon
//
//  Created by PETRUS VAN DE PUT on 14/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit
import XCTest

class KNAPIResponseTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        var test: KNAPIResponse = KNAPIResponse()
        XCTAssertTrue(test.hasErrors, "")
        
        var json: NSDictionary = NSDictionary()
        var test1: KNAPIResponse = KNAPIResponse(fromJsonObject: json)
        XCTAssertNotNil(test1.status!, "It should be not nil")
        
        var error: NSDictionary = NSDictionary(objectsAndKeys: "", "param", "","code", "", "message")
        var test2: KNAPIResponse.APIError = KNAPIResponse.APIError(errorNode: error)
        XCTAssertEqual(test2.errorCode, "", "It should be empty")
        XCTAssertEqual(test2.errorMessage, "", "It should be empty")
        XCTAssertEqual(test2.parameter, "", "It should be empty")
    }
    
    
    /*
    func testErrorAPIResponse(){
        
        // Declare our expectation
        let apiResponseExpectation = expectationWithDescription("ready")
        KNCommunicationsManager.sharedInstance.loginUserWithPassword("peter", password:"")
            { (success: Bool,apiResponse:KNAPIResponse) -> () in
               
                if(success) {
                    // And fulfill the expectation...
                    apiResponseExpectation.fulfill()
                   XCTAssertTrue(apiResponse.hasErrors,"API response should return errors")
                }
                
        }
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    */
}
