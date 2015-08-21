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

class MMTUmModelStoreTests : XCTestCase
{
    // MARK: Test methods
    
    func testForecastLenght()
    {
        let store = MMTUmModelStore(date: NSDate())
        XCTAssertEqual(60, store.forecastLength)
    }
    
    func testForecastStartDateMidnight()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T08:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T00:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDate6am()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T15:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T06:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDate12am()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T20:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T12:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDate6pm()
    {
        let date = TT.localFormatter.dateFromString("2015-06-09T01:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-08T18:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDatePreviousDay()
    {
        let date = TT.localFormatter.dateFromString("2015-06-08T04:00")!
        let expectedDate = TT.utcFormatter.dateFromString("2015-06-07T18:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
}