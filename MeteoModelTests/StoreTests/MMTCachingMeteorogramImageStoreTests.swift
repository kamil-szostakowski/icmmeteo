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
        cache = MMTImagesCache(cache: NSCache<NSString, UIImage>())
        mockImageStore = MMTMockMeteorogramImageStore()
        store = MMTCachingMeteorogramImageStore(store: mockImageStore, cache: cache)
        completionExpectation = expectation(description: "completion")
    }
    
    // MARK: Test methods
    func testStoreMeteorogramInCache()
    {
        let startDate = mockImageStore.climateModel.startDate(for: Date())
        let key = "\(mockImageStore.climateModel.type.rawValue)-\(city.name)-\(startDate)"
        
        mockImageStore.meteorogramResult = .success(UIImage())
        
        store.getMeteorogram(for: city, startDate: startDate) {
            guard case .success(_) = $0 else { XCTFail(); return }
            XCTAssertNotNil(self.cache.object(forKey: key))
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreMeteorogramInCacheWhenError()
    {
        let startDate = mockImageStore.climateModel.startDate(for: Date())
        let key = mockImageStore.climateModel.cacheKey(city: city, startDate: startDate)
        
        mockImageStore.meteorogramResult = .failure(.meteorogramFetchFailure)
        
        store.getMeteorogram(for: city, startDate: startDate) {
            guard case let .failure(error) = $0 else { XCTFail(); return }
            XCTAssertEqual(error, .meteorogramFetchFailure)
            XCTAssertNil(self.cache.object(forKey: key))
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testRetreiveMeteorogramFromCache()
    {
        
        let climateModel = mockImageStore.climateModel
        let startDate = climateModel.startDate(for: Date().addingTimeInterval(TimeInterval(hours: 120)))
        let key = mockImageStore.climateModel.cacheKey(city: city, startDate: startDate)

        cache.setObject(UIImage(), forKey: key)
        mockImageStore.meteorogramResult = .failure(.meteorogramNotFound)
        
        store.getMeteorogram(for: city, startDate: startDate) {
            guard case .success(_) = $0 else { XCTFail(); return }
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreLegendInCache()
    {
        let key = mockImageStore.climateModel.cacheKeyForLegend()
        
        mockImageStore.legendResult = .success(UIImage())
        store.getLegend {
            guard case .success(_) = $0 else { XCTFail(); return }
            XCTAssertNotNil(self.cache.object(forKey: key))
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreLegendInCacheWhenError()
    {
        let key = mockImageStore.climateModel.cacheKeyForLegend()
        
        mockImageStore.legendResult = .failure(.meteorogramFetchFailure)
        store.getLegend {
            guard case let .failure(error) = $0 else { XCTFail(); return }
            XCTAssertEqual(error, .meteorogramFetchFailure)
            XCTAssertNil(self.cache.object(forKey: key))
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }

    
    func testRetreiveLegendFromCache()
    {
        let key = mockImageStore.climateModel.cacheKeyForLegend()
        
        cache.setObject(UIImage(), forKey: key)
        mockImageStore.legendResult = .failure(.meteorogramFetchFailure)
        
        store.getLegend {
            guard case .success(_) = $0 else { XCTFail(); return }
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreMapMeteorogramInCache()
    {
        let moment = Date()
        let map = MMTDetailedMap(MMTUmClimateModel(), .Precipitation, 0)
        let key = mockImageStore.climateModel.cacheKey(map: map.type, moment: moment)
        
        mockImageStore.mapResult = [.success(UIImage())]
        store.getMeteorogram(for: map, moment: moment, startDate: moment) {
            guard case .success(_) = $0 else { XCTFail(); return }
            XCTAssertNotNil(self.cache.object(forKey: key))
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testStoreMapMeteorogramInCacheWhenError()
    {
        let moment = Date()
        let map = MMTDetailedMap(MMTUmClimateModel(), .Precipitation, 0)
        let key = mockImageStore.climateModel.cacheKey(map: map.type, moment: moment)
        
        mockImageStore.mapResult = [.failure(.meteorogramFetchFailure)]
        store.getMeteorogram(for: map, moment: moment, startDate: moment) {
            guard case let .failure(error) = $0 else { XCTFail(); return }
            XCTAssertEqual(error, .meteorogramFetchFailure)
            XCTAssertNil(self.cache.object(forKey: key))
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testRetreiveMapMeteorogramFromCache()
    {
        let moment = Date()
        let map = MMTDetailedMap(MMTUmClimateModel(), .Precipitation, 0)
        let key = mockImageStore.climateModel.cacheKey(map: map.type, moment: moment)
        
        mockImageStore.mapResult = [.failure(.meteorogramFetchFailure)]
        cache.setObject(UIImage(), forKey: key)
        
        store.getMeteorogram(for: map, moment: moment, startDate: moment) {
            guard case .success(_) = $0 else { XCTFail(); return }
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }

}
