//
//  MMTWamMeteorogramStoreTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import MobileMeteo

class MMTWamModelStoreTests: XCTestCase
{
    // MARK: Test methods
    
    func testForecastLenght()
    {
        let store = MMTWamModelStore(date: NSDate())
        XCTAssertEqual(84, store.forecastLength)
    }
    
    func testStartForecastDate()
    {
        let expectedDate = TT.utcFormatter.dateFromString("2015-03-11T00:00")!
        let store = MMTWamModelStore(date: TT.localFormatter.dateFromString("2015-03-12T01:34")!)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testHoursFromForecastStart()
    {
        let date = TT.utcFormatter.dateFromString("2015-03-12T15:00")!
        let store = MMTWamModelStore(date: TT.localFormatter.dateFromString("2015-03-12T01:34")!)
        
        XCTAssertEqual(39, store.getHoursFromForecastStartDate(forDate: date))
    }
    
    func testForecastMomentsCount()
    {
        let store = MMTWamModelStore(date: TT.utcFormatter.dateFromString("2015-07-30T00:00")!)
        XCTAssertEqual(28, store.getForecastMoments().count)
    }
    
    func testForecastMoments()
    {
        let store = MMTWamModelStore(date: TT.utcFormatter.dateFromString("2015-07-30T00:00")!)
        let moments = store.getForecastMoments()
        
        XCTAssertEqual(TT.getDate(2015, 7, 30, 3), moments[0].date)
        XCTAssertEqual(TT.getDate(2015, 7, 31, 9), moments[10].date)
        XCTAssertEqual(TT.getDate(2015, 8, 1, 6), moments[17].date)
        XCTAssertEqual(TT.getDate(2015, 8, 2, 12), moments[27].date)
    }
}