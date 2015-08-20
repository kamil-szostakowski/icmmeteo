//
//  MMTCoampsMeteorogramStoreTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import MobileMeteo

class MMTCoampsModelStoreTests: XCTestCase
{
    var store: MMTCoampsModelStore!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        store = MMTCoampsModelStore()
    }
    
    override func tearDown()
    {
        store = nil
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func testForecastLenght()
    {
        XCTAssertEqual(84, store.forecastLength)
    }
    
    func testForecastStartDatePreviousDay()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T04:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-07-12:00")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
    
    func testForecastStartDateMidnight()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T15:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T00:00")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
    
    func testForecastStartDate12am()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T20:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T12:00")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
}