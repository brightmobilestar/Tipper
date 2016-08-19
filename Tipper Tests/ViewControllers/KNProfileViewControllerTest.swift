//
//  KNProfileViewControllerTest.swift
//  Tipper
//
//  Created by Jay N on 1/5/15.
//  Copyright (c) 2015 Knodeit.com. All rights reserved.
//

import XCTest
import UIKit


class KNProfileViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
/*
    func testKNProfileViewController() {
        var storyboard: UIStoryboard = UIStoryboard(name: kTipperModuleStoryboardName, bundle: NSBundle(forClass: self.dynamicType))
        let viewcontroller  = storyboard.instantiateViewControllerWithIdentifier(kProfileViewControllerID) as? KNProfileViewController
        viewcontroller?.loadView()
        XCTAssertNotNil(viewcontroller?, "Get KNProfileViewController failed")
        
        XCTAssertNotNil(viewcontroller?.btnClose, "Close button not connected")
        let closeAction = viewcontroller?.btnClose?.actionsForTarget(viewcontroller!, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(closeAction, "Close button not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(closeAction!.first!.isEqualToString("closeButtonDidTouch:"), "Close button not hooked to closeButtonDidTouch")
        
        XCTAssertNotNil(viewcontroller?.btnAddToFavorite, "Add To Favorite button not connected")
        let addToFavoriteAction = viewcontroller?.btnAddToFavorite?.actionsForTarget(viewcontroller!, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(addToFavoriteAction, "Add To Favorite button not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(addToFavoriteAction!.first!.isEqualToString("bookmarkButtonDidTouch:"), "Add To Favorite button not hooked to bookmarkButtonDidTouch")
        
        XCTAssertNotNil(viewcontroller?.btnTipToFriend, "Tip To Friend button not connected")
        let tipToFriendAction = viewcontroller?.btnTipToFriend?.actionsForTarget(viewcontroller!, forControlEvent: .TouchUpInside)
        XCTAssertNotNil(tipToFriendAction, "Tip To Friend button not connected to a UIControlEventTouchUpInside")
        XCTAssertTrue(tipToFriendAction!.first!.isEqualToString("tipButtonDidTouch:"), "Tip To Friend button not hooked to tipButtonDidTouch")
        
    }
*/
}
