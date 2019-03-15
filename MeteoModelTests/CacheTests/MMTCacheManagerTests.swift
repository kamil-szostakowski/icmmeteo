//
//  MMTCacheTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 14/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTCacheManagerTests: XCTestCase
{
    // MARK: Properties
    let meteorogramCache = MMTMockMeteorogramCache() // Persistent store
    let imagesCache = MMTImagesCache(cache: NSCache<NSString, UIImage>()) // In memory store
    var cache: MMTCacheManager!

    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        cache = MMTCacheManager(meteorogramCache, imagesCache)
    }

    // MARK: Test methods
    func testCacheSyncWhenWeteorogramCacheIsEmpty()
    {
        meteorogramCache.meteorogram = nil
        XCTAssertFalse(cache.sync())
    }
    
    func testCacheSyncWhenWeteorogramCacheIsNotEmpty()
    {
        let assert = { (mgram: MMTMeteorogram) in
            self.meteorogramCache.meteorogram = mgram
            XCTAssertTrue(self.cache.sync())
            XCTAssertNotNil(self.imagesCache.object(forKey: self.expectedCacheKey(for: mgram)))
        }
        
        assert(MMTMeteorogram.loremCity)
        assert(MMTMeteorogram.ipsumCity)
    }
    
    func testCleanupCache()
    {
        meteorogramCache.meteorogram = MMTMeteorogram.loremCity
        imagesCache.setObject(UIImage(), forKey: "key1")
        imagesCache.setObject(UIImage(), forKey: "key2")
        
        cache.cleanup()
        
        XCTAssertNil(meteorogramCache.restore())
        XCTAssertNil(imagesCache.object(forKey: "key1"))
        XCTAssertNil(imagesCache.object(forKey: "key2"))
    }
}

extension MMTCacheManagerTests
{
    fileprivate func expectedCacheKey(for mgram: MMTMeteorogram) -> String
    {
        return mgram.model.cacheKey(city: mgram.city, startDate: mgram.startDate)
    }
}
