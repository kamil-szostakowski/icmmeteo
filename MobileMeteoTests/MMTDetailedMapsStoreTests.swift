//
//  MMTDetailedMapsStore.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MobileMeteo

class MMTDetailedMapsStoreTests: XCTestCase
{
    // MARK: Fetching detailed maps meteorograms tests

    func testFetchOfSupportedDetailedMapMeteorogram()
    {
        let session = MMTMockMeteorogramUrlSession(UIImage(), nil)
        let store = MMTDetailedMapsStore(model: MMTUmClimateModel(), date: Date(), session: session)

        store.getMeteorogram(for: .Fog, moment: Date()){
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertNotNil(image)
            XCTAssertNil(error)
        }
    }

    func testFetchOfUnsupportedDetailedMapMeteorogram()
    {
        let session = MMTMockMeteorogramUrlSession(UIImage(), nil)
        let store = MMTDetailedMapsStore(model: MMTWamClimateModel(), date: Date(), session: session)

        store.getMeteorogram(for: .Fog, moment: Date()){
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, .detailedMapNotSupported)
            XCTAssertNil(image)
        }
    }

    func testBulkFetchOfSupportedDetailedMapMeteorogram()
    {
        let now = Date()
        let session = MMTMockMeteorogramUrlSession(UIImage(), nil)
        let store = MMTDetailedMapsStore(model: MMTUmClimateModel(), date: now, session: session)

        let finishExpectation = self.expectation(description: "Fetch finish expectation")
        
        let moments = [Date(timeInterval: 3*3600, since: now),
                       Date(timeInterval: 6*3600, since: now),
                       Date(timeInterval: 9*3600, since: now)]

        var fetchCount = 0
        store.getMeteorograms(for: moments, map: .Fog) {
            (image: UIImage?, date: Date?, error: MMTError?, finish: Bool) -> Void in

            if finish
            {
                finishExpectation.fulfill()
                XCTAssertEqual(fetchCount, moments.count)
            }
            else
            {
                XCTAssertNotNil(image)
                XCTAssertNotNil(date)
                XCTAssertNil(error)

                fetchCount += 1
            }
        }

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: Calculation forecast moments tests

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
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTDetailedMapsStore(model: MMTUmClimateModel(), date: date)
        var standardMapsCount = 0
        
        for map in MMTUmClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)
            
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
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTDetailedMapsStore(model: MMTCoampsClimateModel(), date: date)
        
        for map in MMTCoampsClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)
            
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
        let date = TT.localFormatter.date(from: "2015-06-08T20:00")!
        let store = MMTDetailedMapsStore(model: MMTCoampsClimateModel(), date: date)
        
        for map in MMTCoampsClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)
            
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
        let date = TT.utcFormatter.date(from: "2015-07-30T00:00")!
        let store = MMTDetailedMapsStore(model: MMTWamClimateModel(), date: date)

        for map in MMTWamClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)

            XCTAssertEqual(28, moments.count)

            XCTAssertEqual(TT.getDate(2015, 7, 29, 15), moments[0])
            XCTAssertEqual(TT.getDate(2015, 7, 30, 21), moments[10])
            XCTAssertEqual(TT.getDate(2015, 7, 31, 18), moments[17])
            XCTAssertEqual(TT.getDate(2015, 8, 2, 0), moments[27])
        }
    }

    func testForecastMomentsOnTurnOfTheMonthForForecastStartAtMidnight()
    {
        let date = TT.utcFormatter.date(from: "2015-07-30T07:00")!
        let store = MMTDetailedMapsStore(model: MMTWamClimateModel(), date: date)

        for map in MMTWamClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)

            XCTAssertEqual(28, moments.count)

            XCTAssertEqual(TT.getDate(2015, 7, 30, 3), moments[0])
            XCTAssertEqual(TT.getDate(2015, 7, 31, 9), moments[10])
            XCTAssertEqual(TT.getDate(2015, 8, 1, 6), moments[17])
            XCTAssertEqual(TT.getDate(2015, 8, 2, 12), moments[27])
        }
    }

    func testForecastMomentsForForecastStartAtMidnight()
    {
        let date = TT.utcFormatter.date(from: "2015-07-08T07:00")!
        let store = MMTDetailedMapsStore(model: MMTWamClimateModel(), date: date)

        for map in MMTWamClimateModel().detailedMaps {
            let moments = store.getForecastMoments(for: map)

            XCTAssertEqual(28, moments.count)

            XCTAssertEqual(TT.getDate(2015, 7, 8, 3), moments[0])
            XCTAssertEqual(TT.getDate(2015, 7, 9, 9), moments[10])
            XCTAssertEqual(TT.getDate(2015, 7, 10, 6), moments[17])
            XCTAssertEqual(TT.getDate(2015, 7, 11, 12), moments[27])
        }
    }

    // MARK: Helpers

    class MMTMockMeteorogramUrlSession: MMTMeteorogramUrlSession
    {
        let image: UIImage?
        let error: MMTError?

        init(_ img: UIImage?, _ err: MMTError?)
        {
            image = img
            error = err

            super.init(redirectionBaseUrl: nil, timeout: 0)
        }

        override func fetchImageFromUrl(_ url: URL, completion: @escaping MMTFetchMeteorogramCompletion)
        {
            completion(image, error)
        }
    }
}
