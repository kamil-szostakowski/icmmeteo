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
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        forecastStore = MMTMockForecastStore()
        forecastStore.result = (Date(), nil)
        
        citiesStore = MMTMockCitiesStore()
        citiesStore.currentCity = MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation())
        
        meteorogramStore = MMTMockMeteorogramStore()
        meteorogramStore.meteorogram = MMTMeteorogram(model: MMTUmClimateModel())
        
        service = MMTForecastService(forecastStore: forecastStore, meteorogramStore: meteorogramStore, citiesStore: citiesStore)
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
    }
    
    func testInitialUpdate()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: CLLocation()) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }
        
        wait(for: [completion], timeout: 2)
    }
    
    func testUpdateRequiredWhenStartDateChanged()
    {
        let newDate = Date().addingTimeInterval(TimeInterval(hours: 10))
        let completion = expectation(description: "update completion")
        
        performInitialUpdate()
        forecastStore.result = (newDate, nil)
        
        service.update(for: CLLocation()) {
            completion.fulfill()
            XCTAssertEqual($0, .newData)
        }
        
        wait(for: [completion], timeout: 2)
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
    }
    
    func testUpdateNotRequiredWhenLocationUnavailable()
    {
        let completion = expectation(description: "update completion")
        
        service.update(for: nil) {
            completion.fulfill()
            XCTAssertEqual($0, .noData)
        }
        
        wait(for: [completion], timeout: 2)
    }
    
    func testUpdateFailureWhenForecastStartDateUpdateFailed()
    {
        forecastStore.result = (nil, .forecastStartDateNotFound)
        let completion = expectation(description: "update completion")
        
        service.update(for: CLLocation()) {
            completion.fulfill()
            XCTAssertEqual($0, .failed)
        }
        
        wait(for: [completion], timeout: 2)
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
    }
    
    // MARK: Helper methods
    func performInitialUpdate()
    {
        let completion = expectation(description: "initial update completion")
        service.update(for: CLLocation()) { _ in completion.fulfill() }
        wait(for: [completion], timeout: 2)
    }
}
