//
//  MMTClimateModelTests.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MobileMeteo

class MMTClimateModelTests: XCTestCase
{
    func testDefaultInitializationForModelUm()
    {
        let model = MMTUmClimateModel()
        
        XCTAssertEqual(model.forecastLength, 60)
        XCTAssertEqual(model.gridNodeSize, 4)
        XCTAssertEqual(model.detailedMapMomentsCount, 20)
        XCTAssertEqual(model.availabilityDelay, TimeInterval(hours: 5))
        XCTAssertEqual(model.detailedMapStartDelay, TimeInterval(hours: 1))
        XCTAssertEqual(model.type, .UM)
    }
    
    func testDetailedMapsCountForModelUm()
    {
        XCTAssertEqual(16, MMTUmClimateModel().detailedMaps.count)
    }
    
    func testDefaultInitializationForModelCoamps()
    {
        let model = MMTCoampsClimateModel()
        
        XCTAssertEqual(model.forecastLength, 84)
        XCTAssertEqual(model.gridNodeSize, 13)
        XCTAssertEqual(model.detailedMapMomentsCount, 28)
        XCTAssertEqual(model.availabilityDelay, TimeInterval(hours: 6))
        XCTAssertEqual(model.detailedMapStartDelay, TimeInterval(hours: 0))
        XCTAssertEqual(model.type, .COAMPS)
    }
    
    func testDetailedMapsCountForModelCoamps()
    {
        XCTAssertEqual(11, MMTCoampsClimateModel().detailedMaps.count)
    }
}
