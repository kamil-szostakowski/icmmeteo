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

class MMTForecastServiceTests: XCTestCase
{
    // Properties
    var service: MMTForecastService!
    var forecastStore: MMTMockForecastStore!
    var meteorogramStore: MMTMockMeteorogramStore!
    var nsCache: NSCache<NSString, UIImage>!
    var cache: MMTImagesCache!
    var expectedKey: String!
    let currentCity = MMTCityProt(name: "Lorem", region: "Loremia")
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
    
        let model = MMTUmClimateModel()
        let startDate = Date.from(2018, 1, 20, 22, 0, 0)
        
        forecastStore = MMTMockForecastStore()
        forecastStore.result = .success(startDate)
        
        var
        meteorogram = MMTMeteorogram(model: model, city: currentCity)
        meteorogram.startDate = startDate
        
        meteorogramStore = MMTMockMeteorogramStore()
        meteorogramStore.meteorogram = .success(meteorogram)
        
        nsCache = NSCache<NSString, UIImage>()
        cache = MMTImagesCache(cache: nsCache)
        expectedKey = model.cacheKey(city: currentCity, startDate: startDate)
        
        service = MMTMeteorogramForecastService(forecastStore: forecastStore, meteorogramStore: meteorogramStore, cache: cache)
    }
    
    // MARK: Test methods
    func testUpdateNotRequired()
    {
        let completion = expectation(description: "update completion")
        performInitialUpdate()
        
        // Redundand update
        service.update(for: currentCity) {
            completion.fulfill()
            XCTAssertEqual($0, .noData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.object(forKey: expectedKey))
    }
    
    func testInitialUpdate()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: currentCity) {
            completion.fulfill()            
            XCTAssertEqual($0, .newData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.object(forKey: expectedKey))
    }
    
    func testUpdateRequiredWhenStartDateChanged()
    {
        let newDate = Date().addingTimeInterval(TimeInterval(hours: 10))
        let completion = expectation(description: "update completion")

        performInitialUpdate()
        forecastStore.result = .success(newDate)

        service.update(for: currentCity) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }

        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.object(forKey: expectedKey))
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
        XCTAssertNotNil(cache.object(forKey: expectedKey))
    }
    
    func testUpdateNotRequiredWhenLocationUnavailable()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: nil) {
            completion.fulfill()
            XCTAssertEqual($0, .noData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNil(cache.object(forKey: expectedKey))
    }
    
    func testUpdateFailureWhenForecastStartDateUpdateFailed()
    {
        forecastStore.result = .failure(.forecastStartDateNotFound)
        let completion = expectation(description: "update completion")
        
        service.update(for: currentCity) {
            completion.fulfill()
            XCTAssertEqual($0, .failed)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNil(cache.object(forKey: expectedKey))
    }
    
    func testUpdateFailureWhenMeteorogramFetchFailed()
    {
        meteorogramStore.meteorogram = .failure(.meteorogramNotFound)
        
        let completion = expectation(description: "update completion")
        
        service.update(for: currentCity) {
            completion.fulfill()
            XCTAssertEqual($0, .failed)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNil(cache.object(forKey: expectedKey))
    }
    
    func testCachingFetchedMeteorogram()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: currentCity) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.object(forKey: expectedKey))
        XCTAssertEqual(service.currentMeteorogram?.city, currentCity)
    }
    
    // MARK: Helper methods
    func performInitialUpdate()
    {
        let completion = expectation(description: "initial update completion")
        service.update(for: currentCity) { _ in completion.fulfill() }
        wait(for: [completion], timeout: 2)
    }
}
