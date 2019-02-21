//
//  MMTPredictionCache.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 20/02/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTPredictionCacheTests: XCTestCase
{
    // MARK: Properties
    var predictionCache = MMTPredictionCache()
    var appGroup = UserDefaults(suiteName: "group.meteo")!
    let expectedDate = Date.from(2019, 3, 20, 10, 15, 20)

    // MARK: Test methods
    func testStoringPrediction()
    {
        predictionCache.storePrediction(for: loremCityMeteorogram)
     
        let interval = expectedDate.timeIntervalSince1970
        XCTAssertEqual(appGroup.object(forKey: "current-city-name") as? String, "Lorem")
        XCTAssertEqual(appGroup.object(forKey: "current-city-start-date") as? Double, interval)
        XCTAssertEqual(appGroup.object(forKey: "current-city-prediction") as? Int, 9)
    }
    
    func testGetPrediction()
    {
        predictionCache.storePrediction(for: loremCityMeteorogram)
        
        let mgram = meteorogram(city: "Lorem", startDate: expectedDate)
        let prediction = predictionCache.getPrediction(for: mgram)!
        
        XCTAssertTrue(prediction.contains(.snow))
        XCTAssertTrue(prediction.contains(.strongWind))
    }
    
    func testGetPredictionWhenCityIsDifferent()
    {
        predictionCache.storePrediction(for: loremCityMeteorogram)
        XCTAssertNil(predictionCache.getPrediction(for: ipsumCityMeteorogram))
    }
    
    func testGetPredictionWhenStartDateIsDifferent()
    {
        predictionCache.storePrediction(for: loremCityMeteorogram)
        
        let mgram = meteorogram(city: "Lorem", startDate: .from(2018, 3, 20, 10, 15, 20))        
        XCTAssertNil(predictionCache.getPrediction(for: mgram))
    }
}

extension MMTPredictionCacheTests
{
    func meteorogram(city: String, startDate: Date) -> MMTMeteorogram
    {
        var
        meteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city: MMTCityProt(name: city, region: ""))
        meteorogram.startDate = startDate
        
        return meteorogram
    }
    
    var loremCityMeteorogram: MMTMeteorogram
    {
        var meteorogram = self.meteorogram(city: "Lorem", startDate: expectedDate)
        meteorogram.prediction = MMTMeteorogram.Prediction([.snow, .strongWind])
        
        return meteorogram
    }
    
    var ipsumCityMeteorogram: MMTMeteorogram
    {
        var meteorogram = self.meteorogram(city: "Ipsum", startDate: expectedDate)
        meteorogram.prediction = MMTMeteorogram.Prediction([.rain, .strongWind])
        
        return meteorogram
    }
}
