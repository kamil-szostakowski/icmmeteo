//
//  MMTCitiesListModelControllerTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 08.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTCitiesListModelControllerTests: XCTestCase
{
    // MARK: Properties
    var citiesStore: MMTMockCitiesStore!
    var modelController: MMTCitiesListModelController!
    var mockDelegate: MMTMockModelControllerDelegate<MMTCitiesListModelController>!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        citiesStore = MMTMockCitiesStore()
        citiesStore.allCities = [
            MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation()),
            MMTCityProt(name: "Ipsum", region: "Ipsumia", location: CLLocation()),
            MMTCityProt(name: "Dolor", region: "Doloria", location: CLLocation()),
            MMTCityProt(name: "Sit", region: "Sitia", location: CLLocation())
        ]
        citiesStore.searchResult = [
            MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation()),
            MMTCityProt(name: "Ipsum", region: "Ipsumia", location: CLLocation()),
        ]
        citiesStore.currentCity = citiesStore.allCities.last!
        citiesStore.error = nil
        
        mockDelegate = MMTMockModelControllerDelegate<MMTCitiesListModelController>()
        modelController = MMTCitiesListModelController(store: citiesStore)
        modelController.delegate = mockDelegate
    }
    
    // MARK: Test methods
    func testInitialization()
    {
        XCTAssertEqual(modelController.cities.count, 0)
        XCTAssertEqual(modelController.searchInput.stringValue, "")
    }
    
    func testActivation()
    {
        let expectations = mockDelegate.awaitModelUpdate(completions: [{
            XCTAssertEqual($0.cities.count, 4)
            XCTAssertEqual($0.searchInput.stringValue, "")
        }])
        
        modelController.activate()
        wait(for: expectations, timeout: 2)
    }
    
    func testSearchWithValidPhrase()
    {
        modelController.activate()
        let expectations = mockDelegate.awaitModelUpdate(completions: [{
            XCTAssertEqual($0.cities.count, 2)
            XCTAssertEqual($0.searchInput.stringValue, "Lor")
        }])
        
        modelController.onSearchPhraseChange(phrase: "Lor")
        modelController.onSearchPhraseChange(phrase: "Lor")
        wait(for: expectations, timeout: 2)
    }
    
    func testSearchWithEmptyPhraseWhenSearchActive()
    {
        modelController.activate()
        modelController.cities = citiesStore.searchResult
        modelController.searchInput = MMTSearchInput("Lorem ipsum")
        
        let expectations = mockDelegate.awaitModelUpdate(completions: [{
            XCTAssertEqual($0.cities.count, 4)
            XCTAssertEqual($0.searchInput.stringValue, "")
        }])
        
        modelController.onSearchPhraseChange(phrase: "")
        wait(for: expectations, timeout: 2)
    }
    
    func testSearchWithEmptyPhraseWhenSearchInactive()
    {
        modelController.activate()
        
        // No model update expected
        let expectations = mockDelegate.awaitModelUpdate(completions: [])
        
        modelController.onSearchPhraseChange(phrase: nil)
        wait(for: expectations, timeout: 2)
        
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.searchInput.stringValue, "")
    }
    
    func testSearchWithInvalidPhraseWhenSearchActive()
    {
        modelController.activate()
        modelController.cities = citiesStore.searchResult
        modelController.searchInput = MMTSearchInput("Lorem ipsum")
        
        // No model update expected
        let expectations = mockDelegate.awaitModelUpdate(completions: [])
        
        modelController.onSearchPhraseChange(phrase: "Lo")
        wait(for: expectations, timeout: 2)
        
        XCTAssertEqual(modelController.cities.count, 2)
        XCTAssertEqual(modelController.searchInput.stringValue, "Lo")
    }
    
    func testSearchWithInvalidPhraseWhenSearchInactive()
    {
        modelController.activate()
        
        // No model update expected
        let expectations = mockDelegate.awaitModelUpdate(completions: [])
        
        modelController.onSearchPhraseChange(phrase: "Lo")
        wait(for: expectations, timeout: 2)
        
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.searchInput.stringValue, "Lo")
    }
    
    func testSearchWhenPhraseChangedButResultSetUnchanged()
    {
        modelController.activate()
        
        let firstSearchExpectations = mockDelegate.awaitModelUpdate(completions: [{
            
            XCTAssertEqual($0.cities.count, 2)
            XCTAssertEqual($0.searchInput.stringValue, "Lorem")
        }])
        
        modelController.onSearchPhraseChange(phrase: "Lorem")
        modelController.onSearchPhraseChange(phrase: "Lorem ipsum")
        wait(for: firstSearchExpectations, timeout: 2)
        
        XCTAssertEqual(modelController.cities.count, 2)
        XCTAssertEqual(modelController.searchInput.stringValue, "Lorem ipsum")
    }
}
