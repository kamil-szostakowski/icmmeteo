//
//  MMTPredictionServiceTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 23/01/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTPredictionModelImplTests: XCTestCase
{
    // MARK: Test methods
    func testPredictionWhenAllPhenomenaDetected()
    {
        let image = UIImage(thisBundle: "2017122300-379-285").cgImage!
        let model = MMTPredictionModelImpl()
        let prediction = try! model.predict(image)
        
        XCTAssertTrue(prediction.contains(.rain))
        XCTAssertTrue(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }
    
    func testPredictionWhenNoPhenomenonDetected()
    {
        let image = UIImage(thisBundle: "2018092900-381-199").cgImage!
        let model = MMTPredictionModelImpl()
        let prediction = try! model.predict(image)
        
        XCTAssertTrue(prediction.isEmpty)
    }
    
//    func testPredictionInputsForInalidImage()
//    {
//        let image = UIImage(thisBundle: "2017122300-379-285-rain.jpeg").cgImage!
//        let model = MMTPredictionModelImpl()
//        XCTAssertThrowsError(try model.predict(image))
//    }
}
