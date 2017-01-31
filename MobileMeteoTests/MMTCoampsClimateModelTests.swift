//
//  MMTCoampsClimateModelTests.swift
//  MobileMeteo
//
//  Created by Kamil on 13.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MobileMeteo

class MMTCoampsClimateModelTests: XCTestCase
{    
    func test_forecastStartDatePreviousDay()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T04:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-07T12:00")!
        
        XCTAssertEqual(expectedDate, MMTCoampsClimateModel().startDate(for: date))
    }
    
    func test_forecastStartDateMidnight()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T15:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T00:00")!
        
        XCTAssertEqual(expectedDate, MMTCoampsClimateModel().startDate(for: date))
    }
    
    func test_forecastStartDate12am()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T12:00")!
        
        XCTAssertEqual(expectedDate, MMTCoampsClimateModel().startDate(for: date))
    }    
}
