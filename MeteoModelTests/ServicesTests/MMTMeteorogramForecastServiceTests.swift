//
//  MMTForecastServiceTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 20.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTMeteorogramForecastServiceTests: XCTestCase
{
    // Properties
    var service: MMTForecastService!
    var forecastStore: MMTMockForecastStore!
    var meteorogramStore: MMTMockMeteorogramStore!
    var cache = MMTMockMeteorogramCache()
    var mlModel = MMTMockPredictionModel([.snow, .rain])
    var meteorogram: MMTMeteorogram!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        let startDate = Date.from(2018, 1, 20, 22, 0, 0)
        
        forecastStore = MMTMockForecastStore()
        forecastStore.result = .success(startDate)
        
        meteorogram = MMTMeteorogram.loremCity
        meteorogram.startDate = startDate
        meteorogram.image = UIImage(thisBundle: "2018092900-381-199-full")
        meteorogram.prediction = nil
        
        meteorogramStore = MMTMockMeteorogramStore()
        meteorogramStore.meteorogram = .success(meteorogram)
                
        service = MMTMeteorogramForecastService(forecastStore, meteorogramStore, cache)
    }
    
    override func tearDown()
    {
        super.tearDown()
        cache.cleanup()
    }
}

// MARK: Prediction tests
extension MMTMeteorogramForecastServiceTests
{
    func testPredictionForCachedMeteorogramWhenNoPredictionExists()
    {
        service = MMTMeteorogramForecastService(forecastStore, meteorogramStore, cache, mlModel)
        cache.store(meteorogram)
        
        verifyPrediction(mlModel.prediction, .noData)
    }
    
    func testPredictionForCachedMeteorogramWhenPredictionAlreadyExists()
    {
        service = MMTMeteorogramForecastService(forecastStore, meteorogramStore, cache, mlModel)
        meteorogram.prediction = [.snow]
        cache.store(meteorogram)
        
        verifyPrediction([.snow], .noData)
    }
    
    func testPredictionForFetchedMeteorogram()
    {
        service = MMTMeteorogramForecastService(forecastStore, meteorogramStore, cache, mlModel)

        verifyPrediction(mlModel.prediction, .newData)
    }
    
    // Helpers
    fileprivate func verifyPrediction(_ prediction: MMTMeteorogram.Prediction?, _ updateStatus: MMTUpdateResult)
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, updateStatus)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertEqual(service.currentMeteorogram?.prediction, prediction)
        XCTAssertEqual(cache.restore()?.prediction, prediction)
    }
}

// MARK: Caching tests
extension MMTMeteorogramForecastServiceTests
{
    func testInitFromCache()
    {
        cache.store(meteorogram)
        verifyCache(meteorogram, .noData)
        XCTAssertEqual(cache.storeCount, 1)
    }
    
    func testCachingFetchedMeteorogram()
    {
        verifyCache(meteorogram, .newData)
        XCTAssertEqual(cache.storeCount, 1)
    }    
    
    fileprivate func verifyCache(_ meteorogram: MMTMeteorogram,
                                 _ updateStatus: MMTUpdateResult)
    {
        let completion = expectation(description: "update completion")
        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, updateStatus)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.restore())
        XCTAssertEqual(service.currentMeteorogram, meteorogram)
        XCTAssertEqual(service.currentMeteorogram?.city, meteorogram.city)
    }
}

// MARK: Status update tests
extension MMTMeteorogramForecastServiceTests
{
    func testUpdateNotRequired()
    {
        let completion = expectation(description: "update completion")
        performInitialUpdate()
        
        // Redundand update
        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, .noData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.restore())
    }
    
    func testInitialUpdate()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.restore())
        XCTAssertEqual(service.currentMeteorogram, meteorogram)
    }
    
    func testUpdateRequiredWhenStartDateChanged()
    {
        let newDate = Date().addingTimeInterval(TimeInterval(hours: 10))
        let completion = expectation(description: "update completion")

        performInitialUpdate()
        forecastStore.result = .success(newDate)

        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }

        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.restore())
    }

    func testUpdateRequiredWhenLocationChanged()
    {
        let newCity = MMTCityProt(name: "Ipsum", region: "Ipsumia", location: CLLocation())
        let completion = expectation(description: "update completion")

        performInitialUpdate()

        service.update(for: newCity) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }

        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.restore())
    }    
    
    // TODO: Consider checking the same condition after sucessfull attempt
    func testUpdateFailureWhenForecastStartDateUpdateFailed()
    {
        forecastStore.result = .failure(.forecastStartDateNotFound)
        let completion = expectation(description: "update completion")
        
        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, .failed)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNil(cache.restore())
        XCTAssertNil(service.currentMeteorogram)
    }
    
    // TODO: Consider checking the same condition after sucessfull attempt
    func testUpdateFailureWhenMeteorogramFetchFailed()
    {
        meteorogramStore.meteorogram = .failure(.meteorogramNotFound)
        let completion = expectation(description: "update completion")
        
        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, .failed)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNil(cache.restore())
        XCTAssertNil(service.currentMeteorogram)
    }
}

// MARK: Helper extension
extension MMTMeteorogramForecastServiceTests
{
    fileprivate func performInitialUpdate()
    {
        let completion = expectation(description: "initial update completion")
        service.update(for: meteorogram.city) { _ in completion.fulfill() }
        wait(for: [completion], timeout: 2)
    }
}
