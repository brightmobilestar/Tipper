//
//  KNImageProcessorTest.swift
//  CloudBeacon
//
//  Created by PETRUS VAN DE PUT on 12/11/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit
import XCTest

class KNImageProcessorTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    internal var portraitImage : UIImage {
        let imageData = NSData(contentsOfURL: NSBundle(forClass: KNImageProcessorTest.self).URLForResource("Portrait", withExtension: "jpg")!)
        let image = UIImage(data: imageData!)
        XCTAssertEqual(image!.size, CGSize(width: 1593, height: 2161), "Verify portrait image size")
        return image!
    }
    
    internal var landscapeImage : UIImage {
        let imageData = NSData(contentsOfURL: NSBundle(forClass: KNImageProcessorTest.self).URLForResource("Landscape", withExtension: "jpg")!)
        let image = UIImage(data: imageData!)
        XCTAssertEqual(image!.size, CGSize(width: 3872, height: 2592), "Verify landscape image size")
        return image!
    }
    
    func testResizePortraitClipped() {
        
        let resized = KNImageProcessor(image: portraitImage).resize(CGSize(width: 500, height: 500), fitMode: KNImageProcessor.Resize.FitMode.Clip).image
        XCTAssertEqual(resized.size.width, CGFloat(500), "Verify width equal")
        XCTAssertEqual(resized.size.height, CGFloat(678), "Verify height clipped, so not equal")
    }
    
    func testResizeLandscapeClipped() {
        let resized = KNImageProcessor(image: landscapeImage).resize(CGSize(width: 500, height: 500), fitMode: KNImageProcessor.Resize.FitMode.Clip).image
        XCTAssertEqual(resized.size.width, CGFloat(747), "Verify width clipped, so not equal")
        XCTAssertEqual(resized.size.height, CGFloat(500), "Verify height equal")
    }
    
    func testResizePortraitCropped() {
        let resized = KNImageProcessor(image: portraitImage).resize(CGSize(width: 500, height: 500), fitMode: KNImageProcessor.Resize.FitMode.Crop).image
        XCTAssertEqual(resized.size, CGSize(width: 500, height: 500), "Verify size equal")
    }
    
    func testResizeLandscapeCropped() {
        let resized = KNImageProcessor(image: landscapeImage).resize(CGSize(width: 500, height: 500), fitMode: KNImageProcessor.Resize.FitMode.Crop).image
        XCTAssertEqual(resized.size, CGSize(width: 500, height: 500), "Verify size equal")
    }
    
    func testResizePortraitScaled() {
        let resized = KNImageProcessor(image: portraitImage).resize(CGSize(width: 500, height: 500), fitMode: KNImageProcessor.Resize.FitMode.Scale).image
        XCTAssertEqual(resized.size, CGSize(width: 500, height: 500), "Verify size equal")
    }
    
    func testResizeLandscapeScaled() {
        let resized = KNImageProcessor(image: landscapeImage).resize(CGSize(width: 500, height: 500), fitMode: KNImageProcessor.Resize.FitMode.Scale).image
        XCTAssertEqual(resized.size, CGSize(width: 500, height: 500), "Verify size equal")
    }
     
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
