//
//  MMTUmMeteorogramStoreTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreGraphics
@testable import MobileMeteo

class MMTUmModelStoreTests : XCTestCase
{
    fileprivate let standardMaps: [MMTDetailedMap] = [.MeanSeaLevelPressure, .TemperatureAndStreamLine, .TemperatureOfSurface, .Wind, .Visibility,
        .Fog, .RelativeHumidityAboveIce, .RelativeHumidityAboveWater, .VeryLowClouds, .LowClouds, .MediumClouds, .HighClouds, .TotalCloudiness]
    
    fileprivate let shorterMaps: [MMTDetailedMap] = [.Precipitation, .Storm, .MaximumGust]
    
    // MARK: Test methods
    
    func testForecastLenght()
    {
        let store = MMTUmModelStore(date: Date())
        XCTAssertEqual(60, store.forecastLength)
    }
    
    
    func testGridNodeSize()
    {
        let store = MMTUmModelStore(date: Date())
        XCTAssertEqual(4, store.gridNodeSize)
    }
    
    func testForecastStartDateMidnight()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T08:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T00:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDate6am()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T15:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T06:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDate12am()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T12:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDate6pm()
    {
        let date = TT.localFormatter.date(from: "2015-06-09T01:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-08T18:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testForecastStartDatePreviousDay()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T04:00")!
        let expectedDate = TT.utcFormatter.date(from: "2015-06-07T18:00")!
        let store = MMTUmModelStore(date: date)
        
        XCTAssertEqual(expectedDate, store.forecastStartDate)
    }
    
    func testMeteorogramSize()
    {
        let store = MMTUmModelStore(date: Date())
        XCTAssertEqual(CGSize(width: 540, height: 660), store.meteorogramSize)
    }
    
    func testLegendSize()
    {
        let store = MMTUmModelStore(date: Date())
        XCTAssertEqual(CGSize(width: 280, height: 660), store.legendSize)
    }
    
    func testDetailedMapsForUmModel()
    {
        let store = MMTUmModelStore(date: Date())
        XCTAssertEqual(16, store.detailedMaps.count)
    }
    
    func testMomentsForStandardMaps()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTUmModelStore(date: date)
        
        for map in standardMaps {
            let moments = store.getForecastMomentsForMap(map)
            
            XCTAssertEqual(21, moments.count)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T13:00")!, moments[0].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[1].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[5].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[14].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T00:00")!, moments[20].date)
        }
    }
    
    func testMomentsCountForShorterMaps()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTUmModelStore(date: date)
        
        for map in shorterMaps {
            let moments = store.getForecastMomentsForMap(map)
            
            XCTAssertEqual(20, moments.count)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[0].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[4].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[13].date)
            XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T00:00")!, moments[19].date)
        }
    }
}
