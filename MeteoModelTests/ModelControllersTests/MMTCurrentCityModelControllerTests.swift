//
//  MMTCurrentCityModelControllerTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 13.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTCurrentCityModelControllerTests: XCTestCase
{
    // MARK: Properties
    var citiesStore: MMTMockCitiesStore!
    var modelController: MMTCurrentCityModelController!
    var mockDelegate: MMTMockModelControllerDelegate<MMTCurrentCityModelController>!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        citiesStore = MMTMockCitiesStore()
        citiesStore.currentCity = MMTCityProt(name: "Sit", region: "Sitia", location: CLLocation())
        citiesStore.error = nil
        
        mockDelegate = MMTMockModelControllerDelegate<MMTCurrentCityModelController>()
        modelController = MMTCurrentCityModelController(store: citiesStore)
        modelController.delegate = mockDelegate
    }    
    
    // MARK: Test methods
    func testInitialization()
    {
        XCTAssertEqual(modelController.currentCity, nil)
        XCTAssertEqual(modelController.requestPending, false)
        XCTAssertEqual(modelController.error, nil)
    }
    
    func testUpdateOfCurrentCity()
    {
        citiesStore.currentCity = MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation())
        
        let expectations = mockDelegate.awaitModelUpdate(completions: [onRequestPending, {
            XCTAssertNil($0.error)
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.currentCity?.name, "Lorem")
        }])
        
        modelController.onLocationChange(location: CLLocation())
        wait(for: expectations, timeout: 2)
    }
    
    func testUpdateOfCurrentCityWithInvalidLocation()
    {
        let expectations = mockDelegate.awaitModelUpdate(completions: [{
            XCTAssertFalse($0.requestPending)
            XCTAssertNil($0.currentCity)
            XCTAssertNil($0.error)
        }])
        
        modelController.onLocationChange(location: nil)
        wait(for: expectations, timeout: 2)
    }
    
    func testUpdateOfCurrentCityWithError()
    {
        citiesStore.error = .locationNotFound
        
        // No updates should be made
        let expectations = mockDelegate.awaitModelUpdate(completions: [onRequestPending, {
            XCTAssertEqual($0.error, .locationNotFound)
            XCTAssertNil($0.currentCity)
        }])
        
        modelController.onLocationChange(location: CLLocation())
        wait(for: expectations, timeout: 2)
        
        XCTAssertNil(modelController.currentCity)
    }
    
    func testUpdateOfCurrentCityWithSameCity()
    {
        let expectations = mockDelegate.awaitModelUpdate(completions: [onRequestPending, {
            XCTAssertEqual($0.currentCity?.name, "Sit")
        }, onRequestPending])
        
        modelController.onLocationChange(location: CLLocation())
        modelController.onLocationChange(location: CLLocation())
        wait(for: expectations, timeout: 2)
    }
    
    // MARK: Helper methods
    func onRequestPending(controller: MMTCurrentCityModelController)
    {
        XCTAssertNil(controller.error)
        XCTAssertTrue(controller.requestPending)
    }
}
