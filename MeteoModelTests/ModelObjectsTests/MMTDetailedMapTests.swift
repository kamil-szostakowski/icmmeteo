//
//  MMTDetailedMapTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 23.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTDetailedMapTests: XCTestCase
{
    // MARK: Calculation forecast moments tests
    func testMomentsForStandardMapsForUmModel()
    {
        let model = MMTUmClimateModel()
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let startDate = model.startDate(for: date)
        var standardMapsCount = 0
        
        for map in model.detailedMaps {
            let moments = map.forecastMoments(for: startDate)
            
            if map.momentsOffset == 0
            {
                XCTAssertEqual(21, moments.count)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T13:00")!, moments[0])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[1])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[5])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[14])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T00:00")!, moments[20])
                
                standardMapsCount += 1
            }
        }
        
        XCTAssertGreaterThan(standardMapsCount, 0)
    }
    
    func testMomentsCountForShorterMapsForUmModel()
    {
        let model = MMTUmClimateModel()
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let startDate = model.startDate(for: date)
        var standardMapsCount = 0
        
        for map in model.detailedMaps {
            let moments = map.forecastMoments(for: startDate)
            
            if map.momentsOffset == 1
            {
                XCTAssertEqual(20, moments.count)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[0])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[4])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[13])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T00:00")!, moments[19])
                
                standardMapsCount += 1
            }
        }
        
        XCTAssertGreaterThan(standardMapsCount, 0)
    }
    
    func testMomentsForStandardMapsForCoampsModel()
    {
        let model = MMTCoampsClimateModel()
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let startDate = model.startDate(for: date)
        
        for map in MMTCoampsClimateModel().detailedMaps {
            let moments = map.forecastMoments(for: startDate)
            
            if map.momentsOffset == 0
            {
                XCTAssertEqual(29, moments.count)
                
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T12:00")!, moments[0])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[5])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[14])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T09:00")!, moments[23])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-12T00:00")!, moments[28])
            }
        }
    }
    
    func testMomentsCountForShorterMapsForCoampsModel()
    {
        let model = MMTCoampsClimateModel()
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let startDate = model.startDate(for: date)
        
        for map in MMTCoampsClimateModel().detailedMaps {
            let moments = map.forecastMoments(for: startDate)
            
            if map.momentsOffset == 1
            {
                XCTAssertEqual(28, moments.count)
                
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[0])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T06:00")!, moments[5])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T09:00")!, moments[14])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T12:00")!, moments[23])
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-12T00:00")!, moments[27])
            }
        }
    }
    
    func testForecastMomentsOnTurnOfTheMonthForForecastStartAt12am()
    {
        let model = MMTWamClimateModel()
        let date = TT.utcFormatter.date(from: "2015-07-30T00:00")!
        let startDate = model.startDate(for: date)
        
        for map in MMTWamClimateModel().detailedMaps {
            let moments = map.forecastMoments(for: startDate)
            
            XCTAssertEqual(28, moments.count)
            
            XCTAssertEqual(TT.getDate(2015, 7, 29, 15), moments[0])
            XCTAssertEqual(TT.getDate(2015, 7, 30, 21), moments[10])
            XCTAssertEqual(TT.getDate(2015, 7, 31, 18), moments[17])
            XCTAssertEqual(TT.getDate(2015, 8, 2, 0), moments[27])
        }
    }
    
    func testForecastMomentsOnTurnOfTheMonthForForecastStartAtMidnight()
    {
        let model = MMTWamClimateModel()
        let date = TT.utcFormatter.date(from: "2015-07-30T07:00")!
        let startDate = model.startDate(for: date)
        
        for map in MMTWamClimateModel().detailedMaps {
            let moments = map.forecastMoments(for: startDate)
            
            XCTAssertEqual(28, moments.count)
            
            XCTAssertEqual(TT.getDate(2015, 7, 30, 3), moments[0])
            XCTAssertEqual(TT.getDate(2015, 7, 31, 9), moments[10])
            XCTAssertEqual(TT.getDate(2015, 8, 1, 6), moments[17])
            XCTAssertEqual(TT.getDate(2015, 8, 2, 12), moments[27])
        }
    }
    
    func testForecastMomentsForForecastStartAtMidnight()
    {
        let model = MMTWamClimateModel()
        let date = TT.utcFormatter.date(from: "2015-07-08T07:00")!
        let startDate = model.startDate(for: date)
        
        for map in MMTWamClimateModel().detailedMaps {
            let moments = map.forecastMoments(for: startDate)
            
            XCTAssertEqual(28, moments.count)
            
            XCTAssertEqual(TT.getDate(2015, 7, 8, 3), moments[0])
            XCTAssertEqual(TT.getDate(2015, 7, 9, 9), moments[10])
            XCTAssertEqual(TT.getDate(2015, 7, 10, 6), moments[17])
            XCTAssertEqual(TT.getDate(2015, 7, 11, 12), moments[27])
        }
    }
    
    func testForecastMomentsWithTooBigOffset()
    {
        let map = MMTDetailedMap(MMTUmClimateModel(), .Precipitation, 30)
        let date = TT.utcFormatter.date(from: "2015-07-08T07:00")!
        
        XCTAssertEqual(map.forecastMoments(for: date).count, 0)
    }
}
