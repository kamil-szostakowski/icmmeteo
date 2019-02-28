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
    var city: MMTCityProt!
    var meteorogram: MMTMeteorogram!
    
    // MARK: Helper methods
    
    override func setUp()
    {
        super.setUp()
        city = MMTCityProt(name: "Lorem", region: "Loremia")
        meteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city: city)
    }
    
    // MARK: Test methods    
    func testPrediction_1()
    {
        meteorogram.image = UIImage(thisBundle: "2017122300-379-285-full")
        let prediction = try! MMTCoreMLPredictionModel().predict(meteorogram)

        XCTAssertTrue(prediction.contains(.rain))
        XCTAssertFalse(prediction.contains(.snow))
        XCTAssertTrue(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }

    func testPrediction_2()
    {
        meteorogram.image = UIImage(thisBundle: "2018092900-381-199-full")
        let prediction = try! MMTCoreMLPredictionModel().predict(meteorogram)

        XCTAssertFalse(prediction.contains(.rain))
        XCTAssertFalse(prediction.contains(.snow))
        XCTAssertFalse(prediction.contains(.strongWind))
        XCTAssertFalse(prediction.contains(.clouds))
    }

    func testPrediction_3()
    {
        meteorogram.image = UIImage(thisBundle: "2017122000-432-277-full")
        let prediction = try! MMTCoreMLPredictionModel().predict(meteorogram)

        XCTAssertTrue(prediction.contains(.snow))
        XCTAssertFalse(prediction.contains(.rain))
        XCTAssertTrue(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }
    
    func testPrediction_4()
    {
        meteorogram.image = UIImage(thisBundle: "2018091218-379-285-full")
        let prediction = try! MMTCoreMLPredictionModel().predict(meteorogram)
        
        XCTAssertFalse(prediction.contains(.rain))
        XCTAssertFalse(prediction.contains(.snow))
        XCTAssertFalse(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }
    
    func testPrediction_5()
    {
        meteorogram.image = UIImage(thisBundle: "2018081406-390-152-full")
        let prediction = try! MMTCoreMLPredictionModel().predict(meteorogram)
        
        XCTAssertFalse(prediction.contains(.rain))
        XCTAssertFalse(prediction.contains(.snow))
        XCTAssertTrue(prediction.contains(.strongWind))
        XCTAssertTrue(prediction.contains(.clouds))
    }
    
    func testPredictionPerformance()
    {
        let model = MMTCoreMLPredictionModel()
        let images = [
            UIImage(thisBundle: "2018081406-390-152-full"),
            UIImage(thisBundle: "2018092900-381-199-full"),
            UIImage(thisBundle: "2017122000-432-277-full"),
            UIImage(thisBundle: "2018091218-379-285-full"),
            UIImage(thisBundle: "2018081406-390-152-full")
        ]
        
        measure {
            for img in images {
                meteorogram.image = img
                _ = try? model.predict(meteorogram)
            }
        }
    }
}
