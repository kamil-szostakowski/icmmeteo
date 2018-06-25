//
//  MMTDetailedMapsStore.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTMeteorogramStoreTests: XCTestCase
{
    // MARK: Properties
    var city: MMTCityProt!
    var forecastStore: MMTMockForecastStore!
    var imageStore: MMTMockMeteorogramImageStore!
    var meteorogramStore: MMTMeteorogramStore!
    var completionExpectation: XCTestExpectation!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        city = MMTCityProt(name: "Lorem", region: "", location: CLLocation())
        
        forecastStore = MMTMockForecastStore()
        forecastStore.result = .success(Date())
        
        imageStore = MMTMockMeteorogramImageStore()
        imageStore.meteorogramResult = .success(UIImage())
        imageStore.legendResult = .success(UIImage())
        
        meteorogramStore = MMTMeteorogramStore(forecastStore, imageStore)
        completionExpectation = expectation(description: "completion")
    }
    
    // MARK: Test methods
    func testFetchOfFullMeteorogram()
    {
        let startDate = Date()
        forecastStore.result = .success(startDate)
        
        meteorogramStore.meteorogram(for: city) {
            guard case let .success(meteorogram) = $0 else { XCTFail(); return }
            XCTAssertEqual(meteorogram.startDate, startDate)
            XCTAssertNotNil(meteorogram.legend)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
    func testFetchOfMeteorogramWithoutStartDate()
    {
        forecastStore.result = .failure(.forecastStartDateNotFound)
        
        meteorogramStore.meteorogram(for: city) {
            guard case let .success(meteorogram) = $0 else { XCTFail(); return }
            XCTAssertEqual(meteorogram.startDate, MMTUmClimateModel().startDate(for: Date()))
            XCTAssertNotNil(meteorogram.legend)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
    func testFetchOfMeteorogramWithoutLegend()
    {
        imageStore.legendResult = .failure(.meteorogramFetchFailure)
        
        meteorogramStore.meteorogram(for: city) {
            guard case let .success(meteorogram) = $0 else { XCTFail(); return }
            XCTAssertNil(meteorogram.legend)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
    func testFailedFetchOfMeteorogram()
    {
        imageStore.meteorogramResult = .failure(.meteorogramFetchFailure)
        
        meteorogramStore.meteorogram(for: city) {
            guard case let .failure(error) = $0 else { XCTFail(); return }
            XCTAssertEqual(error, .meteorogramFetchFailure)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
}
