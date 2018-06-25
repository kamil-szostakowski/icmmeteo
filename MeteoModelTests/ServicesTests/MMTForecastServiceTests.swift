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
    var citiesStore: MMTMockCitiesStore!
    var nsCache: NSCache<NSString, UIImage>!
    var cache: MMTImagesCache!
    var expectedKey: String!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
    
        let model = MMTUmClimateModel()
        let startDate = Date.from(2018, 1, 20, 22, 0, 0)
        let currentCity = MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation())
        
        forecastStore = MMTMockForecastStore()
        forecastStore.result = .success(startDate)
        
        citiesStore = MMTMockCitiesStore()
        citiesStore.currentCity = currentCity
        
        meteorogramStore = MMTMockMeteorogramStore()
        meteorogramStore.meteorogram = MMTMeteorogram(model: model)
        
        nsCache = NSCache<NSString, UIImage>()
        cache = MMTImagesCache(cache: nsCache)
        expectedKey = model.cacheKey(city: currentCity, startDate: startDate)
        
        service = MMTForecastService(forecastStore: forecastStore, meteorogramStore: meteorogramStore, citiesStore: citiesStore, cache: cache)
    }
    
    // MARK: Test methods
    func testUpdateNotRequired()
    {
        let completion = expectation(description: "update completion")
        performInitialUpdate()
        
        // Redundand update
        service.update(for: CLLocation()) {
            completion.fulfill()
            XCTAssertEqual($0, .noData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.object(forKey: expectedKey))
    }
    
    func testInitialUpdate()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: CLLocation()) {
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
        
        service.update(for: CLLocation()) {
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
        citiesStore.currentCity = newCity
        
        service.update(for: CLLocation()) {
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
        
        service.update(for: CLLocation()) {
            completion.fulfill()
            XCTAssertEqual($0, .failed)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNil(cache.object(forKey: expectedKey))
    }
    
    func testUpdateFailureWhenLocationUpdateFailed()
    {
        citiesStore.currentCity = nil
        citiesStore.error = .locationNotFound
        
        let completion = expectation(description: "update completion")
        
        service.update(for: CLLocation()) {
            completion.fulfill()
            XCTAssertEqual($0, .failed)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNil(cache.object(forKey: expectedKey))
    }
    
    func testUpdateFailureWhenMeteorogramFetchFailed()
    {
        meteorogramStore.meteorogram = nil
        meteorogramStore.error = .meteorogramNotFound
        
        let completion = expectation(description: "update completion")
        
        service.update(for: CLLocation()) {
            completion.fulfill()
            XCTAssertEqual($0, .failed)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNil(cache.object(forKey: expectedKey))
    }
    
    func testCachingFetchedMeteorogram()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: CLLocation()) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }
        
        wait(for: [completion], timeout: 2)
        XCTAssertNotNil(cache.object(forKey: expectedKey))
    }
    
    // MARK: Helper methods
    func performInitialUpdate()
    {
        let completion = expectation(description: "initial update completion")
        service.update(for: CLLocation()) { _ in completion.fulfill() }
        wait(for: [completion], timeout: 2)
    }
}
