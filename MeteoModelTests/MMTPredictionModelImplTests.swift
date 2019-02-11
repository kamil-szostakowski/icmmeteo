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
    func testPrediction_1()
    {
        let image = UIImage(thisBundle: "2017122300-379-285-full").cgImage!
        let prediction = try! MMTPredictionModelImpl().predict(image)

        XCTAssertTrue(prediction.contains(.rain))
        XCTAssertFalse(prediction.contains(.snow))
        XCTAssertTrue(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }

    func testPrediction_2()
    {
        let image = UIImage(thisBundle: "2018092900-381-199-full").cgImage!
        let prediction = try! MMTPredictionModelImpl().predict(image)

        XCTAssertFalse(prediction.contains(.rain))
        XCTAssertFalse(prediction.contains(.snow))
        XCTAssertFalse(prediction.contains(.strongWind))
        XCTAssertFalse(prediction.contains(.clouds))
    }

    func testPrediction_3()
    {
        let image = UIImage(thisBundle: "2017122000-432-277-full").cgImage!
        let prediction = try! MMTPredictionModelImpl().predict(image)

        XCTAssertTrue(prediction.contains(.snow))
        XCTAssertFalse(prediction.contains(.rain))
        XCTAssertTrue(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }
    
    func testPrediction_4()
    {
        let image = UIImage(thisBundle: "2018091218-379-285-full").cgImage!
        let prediction = try! MMTPredictionModelImpl().predict(image)
        
        XCTAssertFalse(prediction.contains(.rain))
        XCTAssertFalse(prediction.contains(.snow))
        XCTAssertFalse(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }
    
    func testPrediction_5()
    {
        let image = UIImage(thisBundle: "2018081406-390-152-full").cgImage!
        let prediction = try! MMTPredictionModelImpl().predict(image)
        
        XCTAssertFalse(prediction.contains(.rain))
        XCTAssertFalse(prediction.contains(.snow))
        XCTAssertTrue(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }
    
    func testPredictionPerformance()
    {
        let model = MMTPredictionModelImpl()
        let images = [
            UIImage(thisBundle: "2018081406-390-152-full").cgImage!,
            UIImage(thisBundle: "2018092900-381-199-full").cgImage!,
            UIImage(thisBundle: "2017122000-432-277-full").cgImage!,
            UIImage(thisBundle: "2018091218-379-285-full").cgImage!,
            UIImage(thisBundle: "2018081406-390-152-full").cgImage!
        ]
        
        measure {
            for img in images { _ = try? model.predict(img) }                
        }
    }
}
