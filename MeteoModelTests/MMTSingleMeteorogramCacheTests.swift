//
//  MMTPredictionCache.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 20/02/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTSingleMeteorogramCacheTests: XCTestCase
{
    // MARK: Properties
    var predictionCache = MMTSingleMeteorogramCache()
    var appGroup = UserDefaults(suiteName: "group.com.szostakowski.meteo")!
    let expectedDate = Date.from(2019, 3, 20, 10, 15, 20)

    // MARK: Setup methods
    override func setUp() {
        super.setUp()
        
        let expect = expectation(description: "Init expectation")
        predictionCache.store(meteorogram: loremCityMeteorogram) {_ in expect.fulfill() }
        wait(for: [expect], timeout: 5.0)
    }
    
    // MARK: Test methods
    func testStoringPrediction()
    {
        let interval = expectedDate.timeIntervalSince1970
        
        XCTAssertEqual(self.appGroup.object(forKey: "city-name") as? String, "Lorem")
        XCTAssertEqual(self.appGroup.object(forKey: "city-region") as? String, "xyz")
        XCTAssertEqual(self.appGroup.object(forKey: "city-lat") as? Double, 1.0)
        XCTAssertEqual(self.appGroup.object(forKey: "city-lng") as? Double, 2.0)
        XCTAssertEqual(self.appGroup.object(forKey: "met-start-date") as? Double, interval)
        XCTAssertEqual(self.appGroup.object(forKey: "met-prediction") as? Int, 9)
        XCTAssertEqual(self.appGroup.object(forKey: "met-model") as? String, "UM")
    }
    
    func testRestoreMeteorogram()
    {
        let expect = expectation(description: "Completion expectation")
        predictionCache.restoreMeteorogram {
            
            XCTAssertEqual($0?.city.name, "Lorem")
            XCTAssertEqual($0?.city.region, "xyz")
            XCTAssertEqual($0?.city.location.coordinate.latitude, 1.0)
            XCTAssertEqual($0?.city.location.coordinate.longitude, 2.0)
            XCTAssertEqual($0?.model.type.rawValue, "UM")
            XCTAssertEqual($0?.startDate, self.expectedDate)
            XCTAssertEqual($0?.prediction?.rawValue, 9)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)
    }
}

// MARK: Helper methods
extension MMTSingleMeteorogramCacheTests
{
    func meteorogram(city: String, startDate: Date) -> MMTMeteorogram
    {
        let location = CLLocation(latitude: 1.0, longitude: 2.0)
        let city = MMTCityProt(name: city, region: "xyz", location: location)
        
        var
        meteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city: city)
        meteorogram.prediction = MMTMeteorogram.Prediction([.snow, .strongWind])
        meteorogram.image = UIImage(thisBundle: "2018092900-381-199-full")
        meteorogram.startDate = startDate
        
        return meteorogram
    }
    
    var loremCityMeteorogram: MMTMeteorogram {
        return self.meteorogram(city: "Lorem", startDate: expectedDate)
    }
}
