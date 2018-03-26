//
//  MMTCachingMeteorogramImageStoreTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 26.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTCachingMeteorogramImageStoreTests: XCTestCase
{
    var city: MMTCityProt!
    var cache: MMTImagesCache!
    var store: MMTCachingMeteorogramImageStore!
    var mockImageStore: MMTMockMeteorogramImageStore!
    var completionExpectation: XCTestExpectation!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        city = MMTCityProt(name: "Lorem", region: "", location: CLLocation())
        cache = NSCache<NSString, UIImage>()
        mockImageStore = MMTMockMeteorogramImageStore()
        store = MMTCachingMeteorogramImageStore(store: mockImageStore, cache: cache)
        completionExpectation = expectation(description: "completion")
    }
    
    // MARK: Test methods
    func testStoreMeteorogramInCache()
    {
        let startDate = mockImageStore.climateModel.startDate(for: Date())
        let key = "\(mockImageStore.climateModel.type.rawValue)-\(city.name)-\(startDate)" as NSString
        
        mockImageStore.meteorogramResult = (UIImage(), nil)
        
        store.getMeteorogram(for: city) { (image, error) in
            
            XCTAssertNotNil(self.cache.object(forKey: key))
            XCTAssertNil(error)
            XCTAssertNotNil(image)            
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreMeteorogramInCacheWhenError()
    {
        let startDate = mockImageStore.climateModel.startDate(for: Date())
        let key = "\(mockImageStore.climateModel.type.rawValue)-\(city.name)-\(startDate)" as NSString
        
        mockImageStore.meteorogramResult = (nil, MMTError.meteorogramFetchFailure)
        
        store.getMeteorogram(for: city) { (image, error) in
            
            XCTAssertNil(self.cache.object(forKey: key))
            XCTAssertNotNil(error)
            XCTAssertNil(image)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testRetreiveMeteorogramFromCache()
    {
        let climateModel = mockImageStore.climateModel
        let startDate = climateModel.startDate(for: Date())
        let key = "\(climateModel.type.rawValue)-\(city.name)-\(startDate)" as NSString

        cache.setObject(UIImage(), forKey: key)
        mockImageStore.meteorogramResult = (nil, MMTError.meteorogramNotFound)
        
        store.getMeteorogram(for: city) { (image, error) in
            
            XCTAssertNil(error)
            XCTAssertNotNil(image)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreLegendInCache()
    {
        let key = "\(mockImageStore.climateModel.type.rawValue)-legend" as NSString
        
        mockImageStore.legendResult = (UIImage(), nil)
        store.getLegend { (image, error) in
         
            XCTAssertNotNil(self.cache.object(forKey: key))
            XCTAssertNil(error)
            XCTAssertNotNil(image)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreLegendInCacheWhenError()
    {
        let key = "\(mockImageStore.climateModel.type.rawValue)-legend" as NSString
        
        mockImageStore.legendResult = (nil, MMTError.meteorogramFetchFailure)
        store.getLegend { (image, error) in
            
            XCTAssertNil(self.cache.object(forKey: key))
            XCTAssertNotNil(error)
            XCTAssertNil(image)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }

    
    func testRetreiveLegendFromCache()
    {
        let key = "\(mockImageStore.climateModel.type.rawValue)-legend" as NSString
        
        cache.setObject(UIImage(), forKey: key)
        mockImageStore.legendResult = (nil, MMTError.meteorogramFetchFailure)
        
        store.getLegend { (image, error) in
            
            XCTAssertNil(error)
            XCTAssertNotNil(image)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreMapMeteorogramInCache()
    {
        let moment = Date()
        let map = MMTDetailedMap(MMTUmClimateModel(), .Precipitation, 0)
        let key = "\(mockImageStore.climateModel.type.rawValue)-\(map.type.rawValue)-\(moment)" as NSString
        
        mockImageStore.mapResult = [(UIImage(), nil)]
        store.getMeteorogram(for: map, moment: moment, startDate: moment) { (image, error) in

            XCTAssertNotNil(self.cache.object(forKey: key))
            XCTAssertNil(error)
            XCTAssertNotNil(image)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreMapMeteorogramInCacheWhenError()
    {
        let moment = Date()
        let map = MMTDetailedMap(MMTUmClimateModel(), .Precipitation, 0)
        let key = "\(mockImageStore.climateModel.type.rawValue)-\(map.type.rawValue)-\(moment)" as NSString
        
        mockImageStore.mapResult = [(nil, MMTError.meteorogramFetchFailure)]
        store.getMeteorogram(for: map, moment: moment, startDate: moment) { (image, error) in
            
            XCTAssertNil(self.cache.object(forKey: key))
            XCTAssertNotNil(error)
            XCTAssertNil(image)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testRetreiveMapMeteorogramFromCache()
    {
        let moment = Date()
        let map = MMTDetailedMap(MMTUmClimateModel(), .Precipitation, 0)
        let key = "\(mockImageStore.climateModel.type.rawValue)-\(map.type.rawValue)-\(moment)" as NSString
        
        mockImageStore.mapResult = [(nil, MMTError.meteorogramFetchFailure)]
        cache.setObject(UIImage(), forKey: key)
        
        store.getMeteorogram(for: map, moment: moment, startDate: moment) { (image, error) in
            
            XCTAssertNil(error)
            XCTAssertNotNil(image)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }

}
