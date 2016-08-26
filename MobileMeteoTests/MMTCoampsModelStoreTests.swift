//
//  MMTCoampsMeteorogramStoreTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreGraphics
@testable import MobileMeteo

class MMTCoampsModelStoreTests: XCTestCase
{
    fileprivate let standardMaps: [MMTDetailedMap] = [.MeanSeaLevelPressure, .TemperatureAndStreamLine, .TemperatureOfSurface, .Wind, .RelativeHumidity]
    fileprivate let shorterMaps: [MMTDetailedMap] = [.Precipitation, .Visibility, .LowClouds, .MediumClouds, .HighClouds, .TotalCloudiness]
    
    // MARK: Test methods
    
    func testForecastLenght()
    {
        let store = MMTCoampsModelStore(date: Date())
        XCTAssertEqual(84, store.forecastLength)
    }
    
    func testGridNodeSize()
    {
        let store = MMTCoampsModelStore(date: Date())
        XCTAssertEqual(13, store.gridNodeSize)
    }
    
    func testForecastStartDatePreviousDay()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T04:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-07T12:00")!
        let store = MMTCoampsModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDateMidnight()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T15:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T00:00")!
        let store = MMTCoampsModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDate12am()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T12:00")!
        let store = MMTCoampsModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testMeteorogramSize()
    {
        let store = MMTCoampsModelStore(date: Date())
        XCTAssertEqual(CGSize(width: 660, height: 570), store.meteorogramSize)
    }
    
    func testLegendSize()
    {
        let store = MMTCoampsModelStore(date: Date())
        XCTAssertEqual(CGSize(width: 280, height: 570), store.legendSize)
    }
    
    func testDetailedMapsForCoampsModel()
    {
        let store = MMTCoampsModelStore(date: Date())
        XCTAssertEqual(11, store.detailedMaps.count)
    }
    
    func testMomentsForStandardMaps()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTCoampsModelStore(date: date)
        
        for map in standardMaps {
            let moments = store.getForecastMomentsForMap(map)
            
            XCTAssertEqual(29, moments.count)
            
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T12:00")!, moments[0].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[5].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[14].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T09:00")!, moments[23].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-12T00:00")!, moments[28].date)
        }
    }
    
    func testMomentsCountForShorterMaps()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTCoampsModelStore(date: date)
        
        for map in shorterMaps {
            let moments = store.getForecastMomentsForMap(map)
            
            XCTAssertEqual(28, moments.count)
            
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[0].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T06:00")!, moments[5].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T09:00")!, moments[14].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T12:00")!, moments[23].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-12T00:00")!, moments[27].date)
        }
    }
}
