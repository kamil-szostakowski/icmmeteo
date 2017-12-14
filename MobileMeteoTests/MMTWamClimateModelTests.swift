//
//  MMTWamMeteorogramStoreTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreGraphics
@testable import MobileMeteo

class MMTWamClimateModelTests: XCTestCase
{
    // MARK: Test methods    

    func testDefaultInitializationForModelWam()
    {
        let model = MMTWamClimateModel()

        XCTAssertEqual(model.forecastLength, 84)
        XCTAssertEqual(model.gridNodeSize, 0)
        XCTAssertEqual(model.detailedMapMomentsCount, 28)
        XCTAssertEqual(model.availabilityDelay, TimeInterval(hours: 7))
        XCTAssertEqual(model.detailedMapStartDelay, 0)
        XCTAssertEqual(model.type, .WAM)
        XCTAssertEqual(model.detailedMaps.count, 3)
    }

    func testStartForecastDate12am()
    {
        let expectedDate = TT.utcFormatter.date(from: "2015-09-02T12:00")!
        let date = TT.localFormatter.date(from: "2015-09-03T08:30")!

        XCTAssertEqual(expectedDate, MMTWamClimateModel().startDate(for: date))
    }
    
    func testStartForecastDateMidnight()
    {
        let expectedDate = TT.utcFormatter.date(from: "2015-03-11T00:00")!
        let date = TT.localFormatter.date(from: "2015-03-11T010:34")!
        
        XCTAssertEqual(expectedDate, MMTWamClimateModel().startDate(for: date))
    }
    
    func testGetDetailedMapTupleForDetiledMapType()
    {
        let model = MMTWamClimateModel()
        
        XCTAssertEqual(model.detailedMap(ofType: .LowClouds)?.type, nil)
        XCTAssertEqual(model.detailedMap(ofType: .TideHeight)?.type, .TideHeight)
    }
}
