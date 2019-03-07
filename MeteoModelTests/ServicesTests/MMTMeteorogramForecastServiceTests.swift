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
        
        meteorogramStore = MMTMockMeteorogramStore()
        meteorogramStore.meteorogram = .success(meteorogram)
                
        service = MMTMeteorogramForecastService(forecastStore: forecastStore, meteorogramStore: meteorogramStore, cache: cache)
    }
    
    // MARK: Test methods
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
    }
    
    func testInitFromCache()
    {
        let completion = expectation(description: "update completion")
        cache.store(meteorogram)
        
        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, .noData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.restore())
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
    }
    
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
    }
    
    func testCachingFetchedMeteorogram()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: meteorogram.city) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.restore())
        XCTAssertEqual(service.currentMeteorogram?.city, meteorogram.city)
    }
    
    // MARK: Helper methods
    func performInitialUpdate()
    {
        let completion = expectation(description: "initial update completion")
        service.update(for: meteorogram.city) { _ in completion.fulfill() }
        wait(for: [completion], timeout: 2)
    }
}
