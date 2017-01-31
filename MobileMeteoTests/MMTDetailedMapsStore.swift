//
//  MMTDetailedMapsStore.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MobileMeteo

class MMTDetailedMapsStoreTests: XCTestCase {
    
    func testMomentsForStandardMapsForUmModel()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTDetailedMapsStore(model: MMTUmClimateModel(), date: date)
        var standardMapsCount = 0
        
        for map in MMTUmClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)
            
            if map.momentsOffset == 0
            {
                XCTAssertEqual(21, moments.count)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T13:00")!, moments[0].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[1].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[5].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[14].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T00:00")!, moments[20].date)
                
                standardMapsCount += 1
            }
        }
        
        XCTAssertGreaterThan(standardMapsCount, 0)
    }
    
    func testMomentsCountForShorterMapsForUmModel()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTDetailedMapsStore(model: MMTUmClimateModel(), date: date)
        var standardMapsCount = 0
        
        for map in MMTUmClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)
            
            if map.momentsOffset == 1
            {
                XCTAssertEqual(20, moments.count)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[0].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[4].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[13].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T00:00")!, moments[19].date)
                
                standardMapsCount += 1
            }
        }
        
        XCTAssertGreaterThan(standardMapsCount, 0)
    }
    
    func testMomentsForStandardMapsForCoampsModel()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTDetailedMapsStore(model: MMTCoampsClimateModel(), date: date)
        
        for map in MMTCoampsClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)
            
            if map.momentsOffset == 0
            {
                XCTAssertEqual(29, moments.count)
                
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T12:00")!, moments[0].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T03:00")!, moments[5].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T06:00")!, moments[14].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T09:00")!, moments[23].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-12T00:00")!, moments[28].date)
            }
        }
    }
    
    func testMomentsCountForShorterMapsForCoampsModel()
    {
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTDetailedMapsStore(model: MMTCoampsClimateModel(), date: date)
        
        for map in MMTCoampsClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)
            
            if map.momentsOffset == 1
            {
                XCTAssertEqual(28, moments.count)
                
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-08T15:00")!, moments[0].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-09T06:00")!, moments[5].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-10T09:00")!, moments[14].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-11T12:00")!, moments[23].date)
                XCTAssertEqual(TT.utcFormatter.date(from: "2015-06-12T00:00")!, moments[27].date)
            }
        }
    }
}
