//
//  MMTUmMeteorogramStoreTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import MobileMeteo

class MMTUmMeteorogramStoreTests : XCTestCase
{
    var store: MMTUmMeteorogramStore!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        store = MMTUmMeteorogramStore()
    }
    
    override func tearDown()
    {
        store = nil
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func testForecastLenght()
    {
        XCTAssertEqual(60, store.forecastLength)
    }
    
    func testForecastStartDateMidnight()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T08:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T00:00")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
    
    func testForecastStartDate6am()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T15:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T06:00")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
    
    func testForecastStartDate12am()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T20:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T12:00")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
    
    func testForecastStartDate6pm()
    {
        let date = TT.localFormatter.dateFromString("2015-06-09T01:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T18:00")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
    
    func testForecastStartDatePreviousDay()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T04:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-07T18:00")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
}