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
    var cache = MMTSingleMeteorogramCache()
    
    var modelController: MMTTodayModelController!
    var modelControllerDelegate: MMTMockModelControllerDelegate<MMTTodayModelController>!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        forecastService.currentMeteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city: city)
        locationService.authorizationStatus = .always

        modelControllerDelegate = MMTMockModelControllerDelegate<MMTTodayModelController>()
        setupModelController(env: .normal)
        setupCache(forecastService.currentMeteorogram!)
    }
    
    // MARK: Test methods
    func testModelUpdateWhenLocationServiceDisabled()
    {
        locationService.authorizationStatus = .unauthorized
        locationService.locationPromise.resolve(with: .failure(.locationNotFound))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertEqual($0.updateResult, .failure(.locationServicesUnavailable))
        })
    }
    
    func testModelUpdateWhenNewForecastDataAvailable_NormalEnv()
    {
        forecastService.status = .newData
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.newData, operation: {
            XCTAssertEqual($0.updateResult, .success(self.forecastService.currentMeteorogram!))
        })
    }
    
    func testInitialModelUpdateWhenNoForecastDataAvailable_NormalEnv()
    {
        forecastService.status = .noData
        forecastService.currentMeteorogram = nil
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.noData, operation: {
            XCTAssertEqual($0.updateResult, .failure(.undetermined))
        })
    }
    
    func testInitialModelUpdateWhenForecastDataFetchFeiled_NormalEnv()
    {
        forecastService.status = .failed
        forecastService.currentMeteorogram = nil
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertEqual($0.updateResult, .failure(.undetermined))
        })
    }
    
    func testModelUpdateWhenLocationNotAvailable_NormalEnv()
    {
        locationService.locationPromise.resolve(with: .failure(.locationNotFound))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertEqual($0.updateResult, .failure(.meteorogramUpdateFailure))
        })
    }
    
    func testModelUpdateWhenMeteorogramIsInCache_LowMemoryEnv()
    {
        setupModelController(env: .memoryConstrained)
        forecastService.status = .newData
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.newData, operation: {
            XCTAssertEqual($0.updateResult, .success(self.forecastService.currentMeteorogram!))
        })
    }
    
    func testModelUpdateWhenMeteorogramNotInCache_LowMemoryEnv()
    {
        setupModelController(env: .memoryConstrained)
        cleanupCache()
        
        forecastService.status = .newData
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.failed, operation: {
            XCTAssertEqual($0.updateResult, .failure(.meteorogramUpdateFailure))
        })
    }
    
    /*
     * - Open the app and let the app fetch forecast for the current location and store it in cahce.
     * - Go to settings and disable location services.
     * - Widget should display error message.
     * - Go to settings and enable location services (Always).
     * - Go back to the app.
     * --> Expected: Widget should display forecast.
     */
    
    func testRestoreCacheWithCurrentForecast()
    {
        setupModelController(env: .normal)
        cleanupCache()
        
        forecastService.status = .noData
        locationService.locationPromise.resolve(with: .success(city))
        
        verifyModelUpdate(.noData, operation: {
            XCTAssertEqual($0.updateResult, .success(self.forecastService.currentMeteorogram!))
            XCTAssertFalse(self.cache.isEmpty)
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
    
    func setupModelController(env: MMTEnvironment)
    {
        modelController = MMTTodayModelController(forecastService, locationService, env)
        modelController.delegate = modelControllerDelegate
    }
    
    func setupCache(_ meteorogram: MMTMeteorogram)
    {
        let expect = expectation(description: "Init expectation")
        cache.store(meteorogram: meteorogram) {_ in expect.fulfill() }
        wait(for: [expect], timeout: 1.0)
    }
    
    func cleanupCache()
    {
        let expect = expectation(description: "Cleanup expectation")
        cache.cleanup { _ in expect.fulfill() }
        wait(for: [expect], timeout: 5.0)
    }
}

extension MMTTodayModelController.UpdateResult: Equatable
{
    public static func == (lhs: MMTTodayModelController.UpdateResult, rhs: MMTTodayModelController.UpdateResult) -> Bool
    {
        if case let .failure(first) = lhs, case let .failure(second) = rhs {
            return first == second
        }
        
        if case let .success(first) = lhs, case let .success(second) = rhs {
            return first.city == second.city
        }
        
        return false
    }
}
