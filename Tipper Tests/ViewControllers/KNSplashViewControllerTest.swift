//
//  KNSplashViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import UIKit
import XCTest



class KNSplashViewControllerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testKNSplashViewController() {
        
        
        var storyboard: UIStoryboard = UIStoryboard(name: kMainStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        //let viewcontroller = storyboard.instantiateViewControllerWithIdentifier("KNSplashViewController") as? KNSplashViewController
        let viewcontroller = storyboard.instantiateInitialViewController() as? KNSplashViewController
        viewcontroller?.loadView()
        XCTAssertNotNil(viewcontroller?, "Get KNSplashViewController successfully")
        
        
        /*
        var storyboard: UIStoryboard = UIStoryboard(name: kMainStoryboardName, bundle: nil)
        //let viewcontroller = storyboard.instantiateInitialViewController() as? KNSplashViewController
        let viewcontroller = storyboard.instantiateViewControllerWithIdentifier("KNSplashViewController") as? KNSplashViewController
        
        viewcontroller?.loadView()

        
        XCTAssertNotNil(viewcontroller?, "Get KNSplashViewController successfully")
   
*/
}

}
