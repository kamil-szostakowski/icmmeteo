//
//  MMTCachedLocationServiceTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 15/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTCachedLocationServiceTests: XCTestCase
{
    // MARK: Properties
    var cache = MMTMockMeteorogramCache()
    var service: MMTCachedLocationService!

    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        service = MMTCachedLocationService(cache)
    }

    // MARK: Test methods
    func testAuthorizationStatus()
    {
        XCTAssertEqual(service.authorizationStatus, .whenInUse)
    }
    
    func testRequestLocationWhenCacheIsEmpty()
    {
        cache.meteorogram = nil
        
        awaitRequestResult(.failure(.locationNotFound))
        XCTAssertNil(service.location)
    }
    
    func testRequestLocationWhenCacheIsNotEmpty()
    {
        cache.meteorogram = MMTMeteorogram.loremCity
        
        awaitRequestResult(.success(MMTMeteorogram.loremCity.city))
        XCTAssertEqual(service.location, MMTMeteorogram.loremCity.city)
    }
    
    func testFailedRequestAfterSuccess()
    {
        cache.meteorogram = MMTMeteorogram.loremCity
        awaitRequestResult(.success(MMTMeteorogram.loremCity.city))
        XCTAssertEqual(service.location, MMTMeteorogram.loremCity.city)
        
        cache.meteorogram = nil
        awaitRequestResult(.failure(.locationNotFound))
        XCTAssertNil(service.location)
    }
}

extension MMTCachedLocationServiceTests
{
    fileprivate func awaitRequestResult(_ result: MMTResult<MMTCityProt>)
    {
        let completion = expectation(description: "Completion expectation")
        service.requestLocation().observe {
            XCTAssertEqual($0, result)
            completion.fulfill()
        }
        
        wait(for: [completion], timeout: 2)
    }
}
