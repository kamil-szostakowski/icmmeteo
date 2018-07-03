//
//  MMTTodayModelControllerTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 30.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
@testable import MeteoModel

class MMTTodayModelControllerTests: XCTestCase
{
    // MARK: Properties
    var city: MMTCityProt!
    var modelController: MMTTodayModelController!
    var locationService: MMTMockLocationService!
    var forecastService: MMTMockForecastService!
    var modelControllerDelegate: MMTMockModelControllerDelegate<MMTTodayModelController>!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        let model = MMTUmClimateModel()
        city = MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation())
        
        forecastService = MMTMockForecastService()
        forecastService.currentMeteorogram = MMTMeteorogram(model: model, city: city)
        
        locationService = MMTMockLocationService()
        locationService.authorizationStatus = .always
        locationService.currentLocation = city.location

        modelControllerDelegate = MMTMockModelControllerDelegate<MMTTodayModelController>()
        
        modelController = MMTTodayModelController(forecastService, locationService)
        modelController.delegate = modelControllerDelegate
    }
    
    // MARK: Test methods
    func testModelUpdateWhenNewDataAvailable()
    {
        forecastService.status = .newData
        
        let completionExpect = expectation(description: "completion expectation")
        let modelUpdateExpect = modelControllerDelegate.awaitModelUpdate(completions: [{
            XCTAssertEqual($0.meteorogram?.city, self.city)
            XCTAssertTrue($0.locationServicesEnabled)
        }])
        
        modelController.onUpdate {
            XCTAssertEqual($0, .newData)
            completionExpect.fulfill()
        }
        
        wait(for: modelUpdateExpect + [completionExpect], timeout: 1, enforceOrder: true)
    }
    
    func testNoModelUpdateWhenNoDataAvailableOnInitialUpdate()
    {
        forecastService.currentMeteorogram = nil
        verifyNoModelUpdate(status: .noData)
        
        XCTAssertNil(modelController.meteorogram)
    }
    
    func testNoModelUpdateWhenNoLocationAvailableOnInitialUpdate()
    {
        locationService.currentLocation = nil
        forecastService.currentMeteorogram = nil
        
        verifyNoModelUpdate(status: .noData)
        XCTAssertNil(modelController.meteorogram)
    }
    
    func testNoModelUpdateWhenNoLocationAvailableOnConsecutiveUpdate()
    {
        forecastService.status = .newData
        performInitialUpdate()
        
        locationService.currentLocation = nil
        forecastService.currentMeteorogram = nil
        
        verifyNoModelUpdate(status: .noData)
        XCTAssertEqual(modelController.meteorogram?.city, city)
    }
    
    func testNoModelUpdateWhenNewDataNotAvailableOnConsecutiveUpdate()
    {
        forecastService.status = .newData
        performInitialUpdate()        
        verifyNoModelUpdate(status: .noData)
        
        XCTAssertEqual(modelController.meteorogram?.city, city)
    }
    
    func testNoModelUpdateWhenInitialUpdateFailed()
    {
        forecastService.currentMeteorogram = nil
        verifyNoModelUpdate(status: .failed)
        
        XCTAssertNil(modelController.meteorogram)
    }
    
    func testNoModelUpdateWhenConsecutiveUpdateFailed()
    {
        forecastService.status = .newData
        performInitialUpdate()
        verifyNoModelUpdate(status: .failed)
        
        XCTAssertEqual(modelController.meteorogram?.city, city)
    }
    
    func testModelUpdateWhenLocationServicesNotAvailable()
    {
        locationService.currentLocation = nil
        verifyLocationServices(status: .unauthorized)
        verifyLocationServices(status: .whenInUse)
    }
}

extension MMTTodayModelControllerTests
{
    // MARK: Helper methods
    func performInitialUpdate()
    {
        let completion = expectation(description: "initial update completion")
        modelController.onUpdate { _ in completion.fulfill() }
        wait(for: [completion], timeout: 1)
    }
    
    func verifyNoModelUpdate(status: MMTUpdateResult)
    {
        modelControllerDelegate.updatesCount = 0
        forecastService.status = status
        
        let completionExpect = expectation(description: "completion expectation")
        let modelUpdateExpect = modelControllerDelegate.awaitModelUpdate(completions: [])
        
        modelController.onUpdate {
            XCTAssertEqual($0, status)
            XCTAssertTrue(self.modelController.locationServicesEnabled)
            completionExpect.fulfill()
        }
        
        wait(for: modelUpdateExpect + [completionExpect], timeout: 1, enforceOrder: true)
    }
    
    func verifyLocationServices(status: MMTLocationAuthStatus)
    {
        locationService.authorizationStatus = status
        modelControllerDelegate.updatesCount = 0
        
        let completionExpect = expectation(description: "completion expectation")
        let modelUpdateExpect = modelControllerDelegate.awaitModelUpdate(completions: [{
            XCTAssertNil($0.meteorogram)
            XCTAssertFalse($0.locationServicesEnabled)
        }])
        
        modelController.onUpdate {
            XCTAssertEqual($0, .failed)
            completionExpect.fulfill()
        }
        
        wait(for: modelUpdateExpect + [completionExpect], timeout: 1, enforceOrder: true)
    }
}
