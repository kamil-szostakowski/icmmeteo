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
    var city = MMTCityProt(name: "Lorem", region: "Loremia")
    var forecastService = MMTMockForecastService()
    var locationService = MMTMockLocationService()
    
    var modelController: MMTTodayModelController!
    var modelControllerDelegate: MMTMockModelControllerDelegate<MMTTodayModelController>!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        forecastService.currentMeteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city: city)
        locationService.authorizationStatus = .whenInUse

        modelControllerDelegate = MMTMockModelControllerDelegate<MMTTodayModelController>()
        modelController = MMTTodayModelController(forecastService, locationService)
        modelController.delegate = modelControllerDelegate
    }
    
    // MARK: Test methods
    func testModelUpdateWhenNewForecastDataAvailable()
    {
        forecastService.status = .newData
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.newData, operation: {
            XCTAssertEqual($0.meteorogram?.city, self.city)
            XCTAssertTrue($0.locationServicesEnabled)
        })
    }
    
    func testModelUpdateWhenNoForecastDataAvailable()
    {
        forecastService.status = .noData
        forecastService.currentMeteorogram = nil
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.noData, operation: {
            XCTAssertNil($0.meteorogram?.city)
            XCTAssertTrue($0.locationServicesEnabled)
        })
    }
    
    func testModelUpdateWhenForecastDataFetchFeiled()
    {
        forecastService.status = .failed
        forecastService.currentMeteorogram = nil
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertNil($0.meteorogram?.city)
            XCTAssertTrue($0.locationServicesEnabled)
        })
    }
    
    func testModelUpdateWhenLocationNotAvailable()
    {
        locationService.locationPromise.resolve(with: .failure(.locationNotFound))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertNil($0.meteorogram?.city)            
            XCTAssertTrue($0.locationServicesEnabled)
        })
    }
    
    func testModelUpdateWhenLocationServiceDisabled()
    {
        locationService.authorizationStatus = .unauthorized
        locationService.locationPromise.resolve(with: .failure(.locationNotFound))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertNil($0.meteorogram?.city)
            XCTAssertFalse($0.locationServicesEnabled)
        })
    }
}

extension MMTTodayModelControllerTests
{
    // MARK: Helper methods
    func verifyModelUpdate(_ status: MMTUpdateResult, operation: @escaping (MMTTodayModelController) -> Void)
    {
        let completion = expectation(description: "completion expectation")
        let modelUpdate = modelControllerDelegate.awaitModelUpdate(completions: [operation])
        
        modelController.onUpdate {
            XCTAssertEqual($0, status)
            completion.fulfill()
        }
        
        wait(for: modelUpdate + [completion], timeout: 0.5, enforceOrder: true)
    }
}
