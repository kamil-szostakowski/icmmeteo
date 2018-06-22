//
//  MMTImagesCacheTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 22.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import XCTest
import CoreLocation
@testable import MeteoModel

class MMTImagesCacheTests: XCTestCase
{
    // MARK: Properties
    var nsCache: NSCache<NSString, UIImage>!
    var cache: MMTImagesCache!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        nsCache = NSCache<NSString, UIImage>()
        cache = MMTImagesCache(cache: nsCache)
    }
    
    override func tearDown()
    {
        nsCache.removeAllObjects()
        super.tearDown()
    }
    
    // MARK: Test methods
    func testSettingDiscardableObject()
    {
        cache.setObject(UIImage(), forKey: "key")
        XCTAssertNotNil(nsCache.object(forKey: "key"))
    }
    
    func testGettingDiscardableObject()
    {
        cache.setObject(UIImage(), forKey: "key")
        XCTAssertNotNil(cache.object(forKey: "key"))
    }
    
    func testGettingNotExistingObject()
    {
        XCTAssertNil(cache.object(forKey: "key"))
    }
    
    func testSettingPinnedObject()
    {
        cache.setPinnedObject(UIImage(), forKey: "key")
        nsCache.removeAllObjects()
        
        XCTAssertNotNil(cache.object(forKey: "key"))
    }
    
    func testKeepSinglePinnedObjectAtOnce()
    {
        cache.setPinnedObject(UIImage(), forKey: "key")
        nsCache.removeAllObjects()
        
        XCTAssertNotNil(cache.object(forKey: "key"))
        
        cache.setPinnedObject(UIImage(), forKey: "newKey")
        nsCache.removeAllObjects()
        
        XCTAssertNotNil(cache.object(forKey: "newKey"))
        XCTAssertNil(cache.object(forKey: "key"))
    }
    
    func testCacheCleanup()
    {
        cache.setObject(UIImage(), forKey: "key1")
        cache.setObject(UIImage(), forKey: "key2")
        cache.setPinnedObject(UIImage(), forKey: "key3")
        
        XCTAssertNotNil(cache.object(forKey: "key1"))
        XCTAssertNotNil(cache.object(forKey: "key2"))
        XCTAssertNotNil(cache.object(forKey: "key3"))
        
        cache.removeAllObjects()
        
        XCTAssertNil(cache.object(forKey: "key1"))
        XCTAssertNil(cache.object(forKey: "key2"))
        XCTAssertNil(cache.object(forKey: "key3"))
    }
}

class MMTImagesCacheKeysTests: XCTestCase
{
    // MARK: Properties
    let city1 = MMTCityProt(name: "Lorem", region: "", location: CLLocation())
    let city2 = MMTCityProt(name: "Ipsum", region: "", location: CLLocation())
    let date1 = Date.from(2018, 1, 10, 12, 32, 0)
    let date2 = Date.from(2017, 10, 1, 20, 12, 30)
    
    // MARK: Test methods
    func testKeyForUmMeteorogramImage()
    {
        let model = MMTUmClimateModel()
        
        XCTAssertEqual(model.cacheKey(city: city1, startDate: date1), "UM-Lorem-2018-01-10 12:32:00 +0000")
        XCTAssertEqual(model.cacheKey(city: city1, startDate: date2), "UM-Lorem-2017-10-01 20:12:30 +0000")
        XCTAssertEqual(model.cacheKey(city: city2, startDate: date1), "UM-Ipsum-2018-01-10 12:32:00 +0000")
        XCTAssertEqual(model.cacheKey(city: city2, startDate: date2), "UM-Ipsum-2017-10-01 20:12:30 +0000")
    }
    
    func testKeyForCoampsMeteorogramImage()
    {
        let model = MMTCoampsClimateModel()
        
        XCTAssertEqual(model.cacheKey(city: city1, startDate: date1), "COAMPS-Lorem-2018-01-10 12:32:00 +0000")
        XCTAssertEqual(model.cacheKey(city: city1, startDate: date2), "COAMPS-Lorem-2017-10-01 20:12:30 +0000")
        XCTAssertEqual(model.cacheKey(city: city2, startDate: date1), "COAMPS-Ipsum-2018-01-10 12:32:00 +0000")
        XCTAssertEqual(model.cacheKey(city: city2, startDate: date2), "COAMPS-Ipsum-2017-10-01 20:12:30 +0000")
    }
    
    func testKeyForDetailedMapImageWithUmModel()
    {
        let model = MMTUmClimateModel()
        
        XCTAssertEqual(model.cacheKey(map: .Precipitation, moment: date1), "UM-Precipitation-2018-01-10 12:32:00 +0000")
        XCTAssertEqual(model.cacheKey(map: .Precipitation, moment: date2), "UM-Precipitation-2017-10-01 20:12:30 +0000")
        XCTAssertEqual(model.cacheKey(map: .Fog, moment: date1), "UM-Fog-2018-01-10 12:32:00 +0000")
        XCTAssertEqual(model.cacheKey(map: .Fog, moment: date2), "UM-Fog-2017-10-01 20:12:30 +0000")
    }
    
    func testKeyForDetailedMapImageWithCoampsModel()
    {
        let model = MMTCoampsClimateModel()

        XCTAssertEqual(model.cacheKey(map: .Precipitation, moment: date1), "COAMPS-Precipitation-2018-01-10 12:32:00 +0000")
        XCTAssertEqual(model.cacheKey(map: .Precipitation, moment: date2), "COAMPS-Precipitation-2017-10-01 20:12:30 +0000")
        XCTAssertEqual(model.cacheKey(map: .Fog, moment: date1), "COAMPS-Fog-2018-01-10 12:32:00 +0000")
        XCTAssertEqual(model.cacheKey(map: .Fog, moment: date2), "COAMPS-Fog-2017-10-01 20:12:30 +0000")
    }
    
    func testKeyForMeteorogramLegend()
    {
        XCTAssertEqual(MMTUmClimateModel().cacheKeyForLegend(), "UM-legend")
        XCTAssertEqual(MMTCoampsClimateModel().cacheKeyForLegend(), "COAMPS-legend")
    }
}
