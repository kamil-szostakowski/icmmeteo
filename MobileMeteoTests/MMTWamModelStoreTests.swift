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

class MMTWamModelStoreTests: XCTestCase
{
    // MARK: Test methods
    
    func testForecastLenght()
    {
        let store = MMTWamModelStore(date: NSDate())
        XCTAssertEqual(84, store.forecastLength)
    }

    func testStartForecastDate12am()
    {
        let expectedDate = TT.utcFormatter.dateFromString("2015-09-02T12:00")!
        let store = MMTWamModelStore(date: TT.localFormatter.dateFromString("2015-09-03T08:30")!)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testStartForecastDateMidnight()
    {
        let expectedDate = TT.utcFormatter.dateFromString("2015-03-11T00:00")!
        let store = MMTWamModelStore(date: TT.localFormatter.dateFromString("2015-03-11T010:34")!)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testHoursFromForecastStartAt12am()
    {
        let date = TT.utcFormatter.dateFromString("2015-03-12T15:31")!
        let store = MMTWamModelStore(date: TT.localFormatter.dateFromString("2015-03-12T01:34")!)
        
        XCTAssertEqual(27, store.getHoursFromForecastStartDate(forDate: date))
    }
    
    func testHoursFromForecastStartAtMidnight()
    {
        let date = TT.utcFormatter.dateFromString("2015-03-12T15:31")!
        let store = MMTWamModelStore(date: TT.localFormatter.dateFromString("2015-03-12T09:34")!)
        
        XCTAssertEqual(15, store.getHoursFromForecastStartDate(forDate: date))
    }
    
    func testForecastMomentsCount()
    {
        let store = MMTWamModelStore(date: TT.utcFormatter.dateFromString("2015-07-30T00:00")!)
        XCTAssertEqual(28, store.getForecastMoments().count)
    }
    
    func testForecastMomentsOnTurnOfTheMonthForForecastStartAt12am()
    {
        let store = MMTWamModelStore(date: TT.utcFormatter.dateFromString("2015-07-30T00:00")!)
        let moments = store.getForecastMoments()
        
        XCTAssertEqual(TT.getDate(2015, 7, 29, 15), moments[0].date)
        XCTAssertEqual(TT.getDate(2015, 7, 30, 21), moments[10].date)
        XCTAssertEqual(TT.getDate(2015, 7, 31, 18), moments[17].date)
        XCTAssertEqual(TT.getDate(2015, 8, 2, 0), moments[27].date)
    }
    
    func testForecastMomentsOnTurnOfTheMonthForForecastStartAtMidnight()
    {
        let store = MMTWamModelStore(date: TT.utcFormatter.dateFromString("2015-07-30T07:00")!)
        let moments = store.getForecastMoments()
        
        XCTAssertEqual(TT.getDate(2015, 7, 30, 3), moments[0].date)
        XCTAssertEqual(TT.getDate(2015, 7, 31, 9), moments[10].date)
        XCTAssertEqual(TT.getDate(2015, 8, 1, 6), moments[17].date)
        XCTAssertEqual(TT.getDate(2015, 8, 2, 12), moments[27].date)
    }
    
    func testForecastMomentsForForecastStartAtMidnight()
    {
        let store = MMTWamModelStore(date: TT.utcFormatter.dateFromString("2015-07-08T07:00")!)
        let moments = store.getForecastMoments()
        
        XCTAssertEqual(TT.getDate(2015, 7, 8, 3), moments[0].date)
        XCTAssertEqual(TT.getDate(2015, 7, 9, 9), moments[10].date)
        XCTAssertEqual(TT.getDate(2015, 7, 10, 6), moments[17].date)
        XCTAssertEqual(TT.getDate(2015, 7, 11, 12), moments[27].date)
    }
    
    func testMeteorogramSize()
    {
        let store = MMTWamModelStore(date: NSDate())
        XCTAssertEqual(CGSize(width: 720, height: 702), store.meteorogramSize)
    }
}
