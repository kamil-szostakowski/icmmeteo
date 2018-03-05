//
//  MMTCitiesIndexTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 28.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
@testable import MeteoModel

class MMTCitiesIndexTests: XCTestCase
{
    var cities: [MMTCityProt]!
    var currentCity: MMTCityProt!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        currentCity = testCity("City Current", false, true)
        
        cities = [
            testCity("City 1", true, false),
            testCity("City 2", true, false),
            testCity("City 3", true, false),
            testCity("City 4", true, true),
            testCity("City 5", false, true),
        ]
    }
    
    override func tearDown()
    {
        cities = nil
        currentCity = nil
        
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func testIndexForCitiesWithCurrentCity()
    {
        let index = MMTCitiesIndex(cities, currentCity: currentCity)
        
        XCTAssertEqual(3, index.sectionCount)
        
        XCTAssertEqual(1, index[0].cities.count)
        XCTAssertEqual(2, index[1].cities.count)
        XCTAssertEqual(3, index[2].cities.count)
        
        XCTAssertEqual(MMTCitiesIndexSectionType.CurrentLocation, index[0].type)
        XCTAssertEqual(MMTCitiesIndexSectionType.Favourites, index[1].type)
        XCTAssertEqual(MMTCitiesIndexSectionType.Capitals, index[2].type)
    }
    
    func testIndexForCitiesWithoutCurrentCity()
    {
        let index = MMTCitiesIndex(cities, currentCity: nil)
        
        XCTAssertEqual(2, index.sectionCount)
        
        XCTAssertEqual(2, index[0].cities.count)
        XCTAssertEqual(3, index[1].cities.count)
        
        XCTAssertEqual(MMTCitiesIndexSectionType.Favourites, index[0].type)
        XCTAssertEqual(MMTCitiesIndexSectionType.Capitals, index[1].type)
    }
    
    func testIndexForSearchResults()
    {
        let index = MMTCitiesIndex(searchResult: cities)
        
        XCTAssertEqual(2, index.sectionCount)
        XCTAssertEqual(5, index[0].cities.count)
        XCTAssertEqual(0, index[1].cities.count)
        
        XCTAssertEqual(MMTCitiesIndexSectionType.SearchResults, index[0].type)
        XCTAssertEqual(MMTCitiesIndexSectionType.NotFound, index[1].type)
    }
    
    func testRetrivingCitiesFromIndex()
    {
        let index = MMTCitiesIndex(cities, currentCity: currentCity)
        
        XCTAssertEqual(2, index[[.Favourites]].count)
        XCTAssertEqual(3, index[[.Capitals]].count)
        XCTAssertEqual(5, index[[.Capitals, .Favourites]].count)
    }
    
    // MARK: Helper methods
    private func testCity(_ name: String, _ capital: Bool, _ favourite: Bool) -> MMTCityProt
    {
        var
        city = MMTCityProt(name: "City Current", region: "", location: CLLocation())
        city.isCapital = capital
        city.isFavourite = favourite
        
        return city
    }
}
