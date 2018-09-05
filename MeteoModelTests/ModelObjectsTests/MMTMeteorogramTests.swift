//
//  MMTMeteorogramTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 28.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTMeteorogramTests: XCTestCase
{
    // MARK: Properties
    let city = MMTCityProt(name: "Lorem", region: "Loremia", location: CLLocation())
    
    // MARK: Test methods
    func testInitializationWithUmModel()
    {
        let model = MMTUmClimateModel()
        let meteorogram = MMTMeteorogram(model: model, city: city)
        
        XCTAssertEqual(meteorogram.city, city)
        XCTAssertEqual(meteorogram.model.type, .UM)
        XCTAssertEqual(meteorogram.startDate, model.startDate(for: Date()))
        XCTAssertNotNil(meteorogram.image)
        XCTAssertNil(meteorogram.legend)
    }
    
    func testInitializationWithCoampsModel()
    {
        let model = MMTCoampsClimateModel()
        let meteorogram = MMTMeteorogram(model: model, city: city)
        
        XCTAssertEqual(meteorogram.city, city)
        XCTAssertEqual(meteorogram.model.type, .COAMPS)
        XCTAssertEqual(meteorogram.startDate, model.startDate(for: Date()))
        XCTAssertNotNil(meteorogram.image)
        XCTAssertNil(meteorogram.legend)
    }
}
