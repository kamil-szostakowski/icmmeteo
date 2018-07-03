//
//  MMTCitiesStoreTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 03.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import MeteoModel

class MMTCoreDataCitiesStoreTests: XCTestCase
{
    // MARK: Properties
    var store: MMTCoreDataCitiesStore!
    var geocoder: MMTMockCityGeocoder!
    var coreData: MMTCoreData!
    
    var allCities = [
        MMTCityProt(name: "Lorem", region: "Loremia"),
        MMTCityProt(name: "Lor-Ipsum", region: "Ipsumia"),
        MMTCityProt(name: "Dolor", region: "Doloria"),
        MMTCityProt(name: "Sit", region: "Sitia"),
        MMTCityProt(name: "Amet", region: "Ametia", favorite: true)
    ]
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        coreData = MMTCoreData(type: NSInMemoryStoreType)
        allCities.forEach { coreData.context.save(entity: $0) }
        coreData.context.saveContextIfNeeded()
        
        geocoder = MMTMockCityGeocoder()
        store = MMTCoreDataCitiesStore(coreData.context, geocoder)
    }
    
    override func tearDown()
    {
        coreData.flushDatabase()
        super.tearDown()
    }
    
    // MARK: Test methods
    func testFetchAll()
    {
        let completionExpect = expectation(description: "Completion expectation")
        let sortedCities = allCities.sorted { $0.name < $1.name }
        
        store.all { cities in
            XCTAssertEqual(sortedCities, cities)
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func testCitiesFromLocalStoreMatchingCriteira()
    {
        let completionExpect = expectation(description: "Completion expectation")
        let expectedCities = [
            MMTCityProt(name: "Lorem", region: "Loremia"),
            MMTCityProt(name: "Dolor", region: "Doloria"),
            MMTCityProt(name: "Lor-Ipsum", region: "Ipsumia"),
        ].sorted { $0.name < $1.name }
        
        store.cities(matching: "Lor") { cities in
            XCTAssertEqual(expectedCities, cities)
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func testCitiesFromGeocoderMatchingCriteira()
    {
        geocoder.citiesMatchingCriteria = [
            MMTCityProt(name: "Consecty", region: "Consecturia", capital: false),
            MMTCityProt(name: "Consect", region: "Consecturia", capital: false),
        ]
     
        let expectedCities = geocoder.citiesMatchingCriteria.sorted { $0.name < $1.name }
        let completionExpect = expectation(description: "Completion expectation")
        
        store.cities(matching: "Consect") { cities in
            XCTAssertEqual(expectedCities, cities)
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func testCitiesMatchingCriteiraWhenResultIsEmpty()
    {
        geocoder.citiesMatchingCriteria = []
        
        let completionExpect = expectation(description: "Completion expectation")
        
        store.cities(matching: "Consect") { cities in
            XCTAssertEqual([], cities)
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func testCityForLocationWhenGeocodeFailure()
    {
        geocoder.cityForLocation = .failure(.locationNotFound)
        
        let completionExpect = expectation(description: "Completion expectation")
        
        store.city(for: CLLocation()) {
            guard case let .failure(error) = $0 else { XCTFail(); return }
            XCTAssertEqual(error, .locationNotFound)
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func testCityForLocationWhenCityIsNotLocal()
    {
        let expectedCity = MMTCityProt(name: "Consect", region: "Consecturia",  capital: false)
        let completionExpect = expectation(description: "Completion expectation")
        
        geocoder.cityForLocation = .success(expectedCity)
        
        store.city(for: CLLocation()) {
            guard case let .success(city) = $0 else { XCTFail(); return }
            XCTAssertEqual(city, expectedCity)
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func testCityForLocationWhenCityIsLocal()
    {
        let completionExpect = expectation(description: "Completion expectation")
        
        geocoder.cityForLocation = .success(MMTCityProt(name: "Lorem", region: "Loremia", capital: false))
        
        store.city(for: CLLocation()) {
            guard case let .success(city) = $0 else { XCTFail(); return }
            XCTAssertEqual(city, MMTCityProt(name: "Lorem", region: "Loremia"))
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
    
    func testMarkCapitalCityAsFavorite()
    {
        verifyLocalCity(matching: "Lorem", favorite: false)
        
        var
        city = allCities.first!
        city.isFavourite = true
        
        store.save(city: city)
        verifyLocalCity(matching: "Lorem", favorite: true)
    }
    
    func testMarkNonCapitalCityAsFavorite()
    {
        let completionExpect = expectation(description: "Completion expectation")
        let city = MMTCityProt(name: "Consect", region: "Consecturia", capital: false, favorite: true)
        
        store.all {
            XCTAssertFalse($0.contains(city))
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
        
        store.save(city: city)
        verifyLocalCity(matching: "Cons", favorite: true, capital: false)
    }
    
    func testMarkCapitalCityAsNonFavorite()
    {
        var city = allCities.last!
        verifyLocalCity(matching: "Amet", favorite: true)
        
        city.isFavourite = false
        store.save(city: city)
        verifyLocalCity(matching: "Amet", favorite: false)
    }
    
    func testMarkNonCapitalCityAsNonFavorite()
    {
        let completionExpect = expectation(description: "Completion expectation")
        var city = MMTCityProt(name: "Consect", region: "Consecturia", capital: false, favorite: true)
        
        store.save(city: city)
        verifyLocalCity(matching: "Cons", favorite: true, capital: false)
        
        city.isFavourite = false
        store.save(city: city)
        
        store.all {
            XCTAssertFalse($0.contains(city))
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 1)
    }
}

extension MMTCoreDataCitiesStoreTests
{
    // MARK: Helper methods
    func verifyLocalCity(matching criteria: String, favorite: Bool, capital: Bool = true)
    {
        let expectOne = expectation(description: "Completion One")
        
        store.cities(matching: criteria) {
            guard let city = $0.first else { XCTFail(); return }
            
            XCTAssertEqual($0.count, 1)
            XCTAssertEqual(city.isCapital, capital)
            XCTAssertEqual(city.isFavourite, favorite)
            
            expectOne.fulfill()
        }
        
        wait(for: [expectOne], timeout: 1)
    }
}

extension MMTCityProt
{
    init(name: String, region: String, capital: Bool = true, favorite: Bool = false)
    {
        self.init(name: name, region: region, location: CLLocation())
        self.isCapital = capital
        self.isFavourite = favorite
    }
}
