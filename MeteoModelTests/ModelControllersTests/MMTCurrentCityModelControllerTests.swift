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
    var sitia = MMTCityProt(name: "Sit", region: "Sitia", location: CLLocation())
    var loremia = MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation())
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        citiesStore = MMTMockCitiesStore()
        citiesStore.currentCity = .success(sitia)
        citiesStore.allCities = [sitia, loremia]
        
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
        citiesStore.currentCity = .success(loremia)
        
        let expectations = mockDelegate.awaitModelUpdate(completions: [onRequestPending, {
            XCTAssertNil($0.error)
            XCTAssertFalse($0.requestPending)
            XCTAssertEqual($0.currentCity?.name, "Lorem")
        }])
        
        modelController.onLocationChange(location: CLLocation())
        wait(for: expectations, timeout: 2)
    }
    
    func testUpdateOfCurrentCityWithInvalidLocationWhenNotPresentBefore()
    {
        // No Model update call expected
        let expectations = mockDelegate.awaitModelUpdate(completions: [])
        
        modelController.onLocationChange(location: nil)
        wait(for: expectations, timeout: 2)
    }
    
    func testUpdateOfCurrentCityWithInvalidLocationWhenPresentBefore()
    {
        guard case let .success(city) = citiesStore.currentCity! else {
            XCTFail()
            return
        }
        
        modelController.currentCity = city
        
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
        citiesStore.currentCity = .failure(.locationNotFound)
        
        // No updates should be made
        let expectations = mockDelegate.awaitModelUpdate(completions: [onRequestPending, {
            XCTAssertEqual($0.error, .locationNotFound)
            XCTAssertNil($0.currentCity)
        }])
        
        modelController.onLocationChange(location: CLLocation())
        wait(for: expectations, timeout: 2)
        
        XCTAssertNil(modelController.currentCity)
    }
    
    func testUpdateOfCurrentCityWithSameNotFavoriteCity()
    {
        verify(city: "Sit", favorite: false)
        
        mockDelegate.updatesCount = 0
        let secondExpectations = mockDelegate.awaitModelUpdate(completions: [onRequestPending])
        
        modelController.onLocationChange(location: CLLocation())
        wait(for: secondExpectations, timeout: 2)
    }
    
    func testUpdateOfCurrentCityWithSameFavoriteCity()
    {
        verify(city: "Sit", favorite: false)
        
        citiesStore.currentCity = .success(sitia)
        sitia.isFavourite = true
        mockDelegate.updatesCount = 0
        citiesStore.allCities = [sitia, loremia]
        
        verify(city: "Sit", favorite: true)
    }
    
    // MARK: Helper methods
    func onRequestPending(controller: MMTCurrentCityModelController)
    {
        XCTAssertNil(controller.error)
        XCTAssertTrue(controller.requestPending)
    }
}

extension MMTCurrentCityModelControllerTests
{
    func verify(city name: String, favorite: Bool)
    {
        let firstExpectations = mockDelegate.awaitModelUpdate(completions: [onRequestPending, {
            XCTAssertEqual($0.currentCity!.name, name)
            XCTAssertEqual($0.currentCity!.isFavourite, favorite)
            }])
        
        modelController.onLocationChange(location: CLLocation())
        wait(for: firstExpectations, timeout: 2)
    }
}
