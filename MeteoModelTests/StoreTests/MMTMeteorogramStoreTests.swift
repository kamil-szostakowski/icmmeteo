//
//  MMTDetailedMapsStore.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTMeteorogramStoreTests: XCTestCase
{
    // MARK: Properties
    var city: MMTCityProt!
    var cache: NSCache<NSString, UIImage>!
    var forecastStore: MMTMockForecastStore!
    var imageStore: MMTMockMeteorogramImageStore!
    var meteorogramStore: MMTMeteorogramStore!
    var completionExpectation: XCTestExpectation!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        cache = NSCache<NSString, UIImage>()
        city = MMTCityProt(name: "Lorem", region: "", location: CLLocation())
        
        forecastStore = MMTMockForecastStore()
        forecastStore.result = (Date(), nil)
        
        imageStore = MMTMockMeteorogramImageStore()
        imageStore.meteorogramResult = (UIImage(), nil)
        imageStore.legendResult = (UIImage(), nil)
        
        meteorogramStore = MMTMeteorogramStore(forecastStore, imageStore, cache)
        completionExpectation = expectation(description: "completion")
    }
    
    // MARK: Test methods
    func testFetchOfFullMeteorogram()
    {
        let startDate = Date()
        forecastStore.result = (startDate, nil)
        
        meteorogramStore.meteorogram(for: city) { (meteorogram, error) in
            XCTAssertEqual(meteorogram?.startDate, startDate)
            XCTAssertNotNil(meteorogram?.legend)
            XCTAssertNotNil(self.cache.object(forKey: "UM-legend"))
            XCTAssertNotNil(self.cache.object(forKey: "UM-Lorem-\(startDate)" as NSString))
            XCTAssertNil(error)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
    func testFetchOfMeteorogramWithoutStartDate()
    {
        forecastStore.result = (nil, .forecastStartDateNotFound)
        
        meteorogramStore.meteorogram(for: city) { (meteorogram, error) in
            XCTAssertEqual(meteorogram?.startDate, MMTUmClimateModel().startDate(for: Date()))
            XCTAssertNotNil(meteorogram?.legend)
            XCTAssertNil(error)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
    func testFetchOfMeteorogramWithoutLegend()
    {
        imageStore.legendResult = (nil, .meteorogramFetchFailure)
        
        meteorogramStore.meteorogram(for: city) { (meteorogram, error) in
            XCTAssertNotNil(meteorogram)
            XCTAssertNil(meteorogram?.legend)
            XCTAssertNil(error)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
    func testFailedFetchOfMeteorogram()
    {
        imageStore.meteorogramResult = (nil, .meteorogramFetchFailure)
        
        meteorogramStore.meteorogram(for: city) { (meteorogram, error) in
            XCTAssertNil(meteorogram)
            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
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

        override func image(from url: URL, completion: @escaping (UIImage?, MMTError?) -> Void) {
            completion(image, error)
        }
    }    
}
