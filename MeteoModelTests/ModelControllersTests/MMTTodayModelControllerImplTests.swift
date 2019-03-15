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

class MMTTodayModelControllerImplTests: XCTestCase
{
    // MARK: Properties
    var city = MMTCityProt(name: "Lorem", region: "Loremia")
    var forecastService = MMTMockForecastService()
    var locationService = MMTMockLocationService()
    
    var modelController: MMTTodayModelControllerImpl!
    var modelControllerDelegate: MMTMockModelControllerDelegate<MMTTodayModelControllerImpl>!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        forecastService.currentMeteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city: city)
        locationService.authorizationStatus = .whenInUse

        modelControllerDelegate = MMTMockModelControllerDelegate<MMTTodayModelControllerImpl>()
        modelController = MMTTodayModelControllerImpl(forecastService, locationService)
        modelController.delegate = modelControllerDelegate
    }
    
    // MARK: Test methods
    func testModelUpdateWhenLocationServiceDisabled()
    {
        locationService.authorizationStatus = .unauthorized
        locationService.locationPromise.resolve(with: .failure(.locationNotFound))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertEqual($0.updateResult, .failure(.locationServicesDisabled))
        })
    }
    
    func testModelUpdateWhenNewForecastDataAvailable()
    {
        forecastService.status = .newData
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.newData, operation: {
            XCTAssertEqual($0.updateResult, .success(self.forecastService.currentMeteorogram!))
        })
    }
    
    func testInitialModelUpdateWhenNoForecastDataAvailable()
    {
        forecastService.status = .noData
        forecastService.currentMeteorogram = nil
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.noData, operation: {
            XCTAssertEqual($0.updateResult, .failure(.forecastUndetermined))
        })
    }
    
    func testInitialModelUpdateWhenForecastDataFetchFailed()
    {
        forecastService.status = .failed
        forecastService.currentMeteorogram = nil
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertEqual($0.updateResult, .failure(.forecastUndetermined))
        })
    }
    
    func testModelUpdateWhenLocationNotAvailable()
    {
        locationService.locationPromise.resolve(with: .failure(.locationNotFound))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertEqual($0.updateResult, .failure(.meteorogramFetchFailure))
        })
    }    
}

extension MMTTodayModelControllerImplTests
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
