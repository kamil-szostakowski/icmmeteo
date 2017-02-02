//
//  MMTClimateModelTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01/01/17.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MobileMeteo

class MMTUmClimateModelTests: XCTestCase
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
        XCTAssertEqual(model.detailedMaps.count, 16)
    }

    func test_forecastStartDateMidnight()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T08:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T00:00")!

        XCTAssertEqual(expectedDate, MMTUmClimateModel().startDate(for: date))
    }

    func test_forecastStartDate6am()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T15:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T06:00")!

        XCTAssertEqual(expectedDate, MMTUmClimateModel().startDate(for: date))
    }

    func test_forecastStartDate12am()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T12:00")!

        XCTAssertEqual(expectedDate, MMTUmClimateModel().startDate(for: date))
    }

    func test_forecastStartDate6pm()
    {
        let date = TT.localFormatter.date(from: "2015-06-09T01:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T18:00")!

        XCTAssertEqual(expectedDate, MMTUmClimateModel().startDate(for: date))
    }

    func test_forecastStartDatePreviousDay()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T04:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-07T18:00")!

        XCTAssertEqual(expectedDate, MMTUmClimateModel().startDate(for: date))
    }    
}
