//
//  MMTDetailedMapsStore.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTDetailedMapsStoreTests: XCTestCase
{
    // MARK: Fetching detailed maps meteorograms tests
//    func testFetchOfSupportedDetailedMapMeteorogram()
//    {
//        let cache = NSCache<NSString, UIImage>()
//        let session = MMTMockMeteorogramUrlSession(UIImage(), nil)
//        let store = MMTDetailedMapsStore(model: MMTUmClimateModel(), date: Date(), session: session, cache: cache)
//
//        store.getMeteorogram(for: .Fog, moment: Date()){
//            (image: UIImage?, error: MMTError?) -> Void in
//
//            XCTAssertNotNil(image)
//            XCTAssertNil(error)
//        }
//    }
//
//    func testFetchOfUnsupportedDetailedMapMeteorogram()
//    {
//        let cache = NSCache<NSString, UIImage>()
//        let session = MMTMockMeteorogramUrlSession(UIImage(), nil)
//        let store = MMTDetailedMapsStore(model: MMTWamClimateModel(), date: Date(), session: session, cache: cache)
//
//        store.getMeteorogram(for: .Fog, moment: Date()){
//            (image: UIImage?, error: MMTError?) -> Void in
//
//            XCTAssertEqual(error, .detailedMapNotSupported)
//            XCTAssertNil(image)
//        }
//    }
//
//    func testBulkFetchOfSupportedDetailedMapMeteorogram()
//    {
//        let now = Date()
//        let model = MMTUmClimateModel()
//        let cache = NSCache<NSString, UIImage>()
//        let session = MMTMockMeteorogramUrlSession(UIImage(), nil)
//        let store = MMTDetailedMapsStore(model: model, date: model.startDate(for: now), session: session, cache: cache)
//
//        let finishExpectation = self.expectation(description: "Fetch finish expectation")
//
//        let moments = [Date(timeInterval: 3*3600, since: now),
//                       Date(timeInterval: 6*3600, since: now),
//                       Date(timeInterval: 9*3600, since: now)]
//
//        var fetchCount = 0
//        store.getMeteorograms(for: moments, map: .Fog) {
//            (image: UIImage?, date: Date?, error: MMTError?, finish: Bool) -> Void in
//
//            if finish
//            {
//                finishExpectation.fulfill()
//                XCTAssertEqual(fetchCount, moments.count)
//            }
//            else
//            {
//                XCTAssertNotNil(image)
//                XCTAssertNotNil(date)
//                XCTAssertNil(error)
//
//                fetchCount += 1
//            }
//        }
//
//        self.waitForExpectations(timeout: 1, handler: nil)
//    }
//
//    func testHoursFromForecastStartAt12am()
//    {
//        let model = MMTWamClimateModel()
//        let date = TT.utcFormatter.date(from: "2015-03-12T15:31")!
//        let startDate = model.startDate(for: TT.localFormatter.date(from: "2015-03-12T01:34")!)
//        let store = MMTDetailedMapsStore(model: MMTWamClimateModel(), date: startDate)
//
//        XCTAssertEqual(27, store.getHoursFromForecastStartDate(forDate: date))
//    }
//
//    func testHoursFromForecastStartAtMidnight()
//    {
//        let model = MMTWamClimateModel()
//        let date = TT.utcFormatter.date(from: "2015-03-12T15:31")!
//        let startDate = model.startDate(for: TT.localFormatter.date(from: "2015-03-12T09:34")!)
//        let store = MMTDetailedMapsStore(model: MMTWamClimateModel(), date: startDate)
//
//        XCTAssertEqual(15, store.getHoursFromForecastStartDate(forDate: date))
//    }

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

        override func image(from url: URL, completion: @escaping MMTFetchMeteorogramCompletion) {
            completion(image, error)
        }
    }
}
