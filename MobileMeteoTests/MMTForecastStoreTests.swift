//
//  MMTClimateModelTests.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MobileMeteo

class MMTForecastStoreTests: XCTestCase
{
    func testHoursFromForecastStartAt12am()
    {
        let model = MMTWamClimateModel()
        let date = TT.utcFormatter.date(from: "2015-03-12T15:31")!
        let startDate = model.startDate(for: TT.localFormatter.date(from: "2015-03-12T01:34")!)
        let store = MMTForecastStore(model: MMTWamClimateModel(), date: startDate)

        XCTAssertEqual(27, store.getHoursFromForecastStartDate(forDate: date))
    }

    func testHoursFromForecastStartAtMidnight()
    {
        let model = MMTWamClimateModel()
        let date = TT.utcFormatter.date(from: "2015-03-12T15:31")!
        let startDate = model.startDate(for: TT.localFormatter.date(from: "2015-03-12T09:34")!)
        let store = MMTForecastStore(model: MMTWamClimateModel(), date: startDate)

        XCTAssertEqual(15, store.getHoursFromForecastStartDate(forDate: date))
    }
}
