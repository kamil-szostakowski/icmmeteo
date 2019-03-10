//
//  MMTPredefinedCitiesFileStoreTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 09/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTPredefinedCitiesFileStoreTests: XCTestCase
{
    let store = MMTPredefinedCitiesFileStore()
    let bundle = Bundle(for: MMTPredefinedCitiesFileStoreTests.self)

    func testGetCitiesFromValidFile()
    {
        let url = bundle.url(forResource: "Cities-valid", withExtension: "json")!
        let cities = store.predefinedCities(from: url).map { $0.name }

        XCTAssertEqual(cities, ["Białystok", "Bydgoszcz", "Gdańsk", "Gorzów Wielkopolski"])
    }
    
    func testGetCitiesFromEmptyFile()
    {
        let url = bundle.url(forResource: "Cities-empty", withExtension: "json")!
        let cities = store.predefinedCities(from: url)
        
        XCTAssertEqual(cities.count, 0)
    }
    
    func testGetCitiesFromInvalidFile()
    {
        let url = bundle.url(forResource: "Cities-invalid", withExtension: "json")!
        let cities = store.predefinedCities(from: url)
        
        XCTAssertEqual(cities.count, 0)
    }
}
