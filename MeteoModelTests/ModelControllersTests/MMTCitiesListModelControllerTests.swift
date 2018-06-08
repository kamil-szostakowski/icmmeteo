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
    var citiesStore: MockCitiesStore!
    var modelController: MMTCitiesListModelController!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        citiesStore = MockCitiesStore()
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
        citiesStore.currentCity = MMTCityProt(name: "Sit", region: "Sitia", location: CLLocation())
        citiesStore.error = nil
        
        modelController = MMTCitiesListModelController(store: citiesStore)
    }
    
    override func tearDown()
    {
        citiesStore = nil
        modelController = nil
        super.tearDown()
    }
    
    // MARK: Test methods
    func testInitialization()
    {
        XCTAssertEqual(modelController.cities.count, 0)
        XCTAssertEqual(modelController.currentCity, nil)
        XCTAssertEqual(modelController.searchInput.stringValue, "")
    }
    
    func testActivation()
    {
        modelController.activate()
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.currentCity, nil)
        XCTAssertEqual(modelController.searchInput.stringValue, "")
    }
    
    func testSearchWithValidPhrase()
    {
        modelController.activate()
        modelController.onSearchPhraseChange(phrase: "Lor")
        
        XCTAssertEqual(modelController.cities.count, 2)
        XCTAssertEqual(modelController.searchInput.stringValue, "Lor")
    }
    
    func testSearchWithEmptyPhrase()
    {
        modelController.activate()
        
        modelController.onSearchPhraseChange(phrase: nil)
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.searchInput.stringValue, "")
        
        modelController.onSearchPhraseChange(phrase: "")
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.searchInput.stringValue, "")
    }
    
    func testSearchWithInalidPhrase()
    {
        modelController.activate()
        
        modelController.onSearchPhraseChange(phrase: "L")
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.searchInput.stringValue, "L")
        
        modelController.onSearchPhraseChange(phrase: "Lo")
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.searchInput.stringValue, "Lo")
    }
    
    func testUpdateOfCurrentCity()
    {
        modelController.activate()
        
        modelController.onLocationChange(location: CLLocation())
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.currentCity?.name, "Sit")
    }
    
    func testUpdateOfCurrentCityWithInvalidLocation()
    {
        modelController.activate()
        
        modelController.onLocationChange(location: nil)
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertNil(modelController.currentCity)
    }
    
    func testUpdateOfCurrentCityWithError()
    {
        citiesStore.error = .locationNotFound
        modelController.activate()
        
        modelController.onLocationChange(location: CLLocation())
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertNil(modelController.currentCity)
    }
    
    func testUpdateOfCurrentCityWithSameCity()
    {
        modelController.activate()
        
        modelController.onLocationChange(location: CLLocation())
        modelController.onLocationChange(location: CLLocation())
        
        XCTAssertEqual(modelController.cities.count, 4)
        XCTAssertEqual(modelController.currentCity?.name, "Sit")
    }
}

class MockCitiesStore: MMTCitiesStore
{
    var allCities = [MMTCityProt]()
    var searchResult = [MMTCityProt]()
    var currentCity: MMTCityProt?
    var error: MMTError?
    
    func all(_ completion: ([MMTCityProt]) -> Void) {
        completion(allCities)
    }
    
    func city(for location: CLLocation, completion: @escaping (MMTCityProt?, MMTError?) -> Void) {
        completion(currentCity, error)
    }
    
    func cities(maching criteria: String, completion: @escaping ([MMTCityProt]) -> Void) {
        completion(searchResult)
    }
    
    func save(city: MMTCityProt) {}
}
