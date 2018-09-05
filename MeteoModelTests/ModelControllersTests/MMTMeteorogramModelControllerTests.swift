//
//  MMTMeteorogramModelControllerTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 12.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTMeteorogramModelControllerTests: XCTestCase
{
    // MARK: Properties
    var city: MMTCityProt!
    var meteorogramStore: MMTMockMeteorogramStore!
    var modelController: MMTMeteorogramModelController!
    var modelControllerDelegate: MMTMockModelControllerDelegate<MMTMeteorogramModelController>!
    var citiesStore: MMTMockCitiesStore!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        citiesStore = MMTMockCitiesStore()
        meteorogramStore = MMTMockMeteorogramStore()
        city = MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation())
        
        modelControllerDelegate = MMTMockModelControllerDelegate<MMTMeteorogramModelController>()
        modelController = MMTMeteorogramModelController(city: city, meteorogramStore: meteorogramStore, citiesStore: citiesStore)
        modelController.delegate = modelControllerDelegate
    }
    
    // MARK: Test methods
    func testInitialization()
    {
        XCTAssertNil(modelController.meteorogram)
        XCTAssertNil(modelController.error)
        XCTAssertEqual(modelController.city.name, "Lorem")
        XCTAssertFalse(modelController.requestPending)
    }
    
    func testDownloadMeteorogram()
    {
        meteorogramStore.meteorogram = .success(MMTMeteorogram(model: MMTUmClimateModel(), city: city))
        
        let updateExpectations = modelControllerDelegate.awaitModelUpdate(completions: [onRequestPending, {
            XCTAssertFalse($0.requestPending)
            XCTAssertNotNil($0.meteorogram)
            XCTAssertNil($0.error)
        }])
        
        modelController.activate()
        wait(for: updateExpectations, timeout: 2)
    }
    
    func testDownloadMeteorogramFailure()
    {
        meteorogramStore.meteorogram = .failure(.meteorogramFetchFailure)
        
        let updateExpectations =  modelControllerDelegate.awaitModelUpdate(completions: [onRequestPending, {
            XCTAssertFalse($0.requestPending)
            XCTAssertNil($0.meteorogram)
            XCTAssertEqual($0.error, MMTError.meteorogramFetchFailure)
        }])
        
        modelController.activate()
        wait(for: updateExpectations, timeout: 2)
    }
    
    func testToggleFavorite()
    {
        XCTAssertFalse(modelController.city.isFavourite)
        
        let updateExpectations =  modelControllerDelegate.awaitModelUpdate(completions: [{
            XCTAssertTrue($0.city.isFavourite)
        }])
        
        modelController.onToggleFavorite()
        wait(for: updateExpectations, timeout: 2)
    }
    
    func testDeactivation()
    {
        modelController.deactivate()
        XCTAssertEqual(modelController.city.name, "Lorem")
    }
    
    // MARK: Helper methods
    func onRequestPending(controller: MMTMeteorogramModelController)
    {
        XCTAssertTrue(controller.requestPending)
        XCTAssertNil(controller.meteorogram)
        XCTAssertNil(controller.error)
    }
}
