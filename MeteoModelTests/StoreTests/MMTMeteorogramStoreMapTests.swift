//
//  MMTMeteorogramStoreMapTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 26.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTMeteorogramStoreMapTests: XCTestCase
{
    // MARK: Properties
    var map: MMTDetailedMap!
    var startDate: Date!
    var forecastStore: MMTMockForecastStore!
    var imageStore: MMTMockMeteorogramImageStore!
    var meteorogramStore: MMTMeteorogramStore!
    var completionExpectation: XCTestExpectation!
    
    let success: MMTResult<UIImage> = .success(UIImage())
    let failure: MMTResult<UIImage> = .failure(.meteorogramFetchFailure)
    
    // MARK: Setup methods
    override func setUp()
    {
        
        super.setUp()
        map = MMTDetailedMap(MMTUmClimateModel(), .Precipitation, 0)
        startDate = Date()
        
        imageStore = MMTMockMeteorogramImageStore()
        forecastStore = MMTMockForecastStore()
        forecastStore.result = .success(startDate)
        
        meteorogramStore = MMTMeteorogramStore(forecastStore, imageStore)
        completionExpectation = expectation(description: "completion")
    }
    
    // MARK: Test methods
    func testFetchOfFullMapMeteorogram()
    {
        let expectedMoments = map.forecastMoments(for: startDate)                
        imageStore.mapResult = expectedMoments.map { _ in success }
        
        meteorogramStore.meteorogram(for: map) {
            guard case let .success(meteorogram) = $0 else { XCTFail(); return }
            XCTAssertEqual(meteorogram.model.type, MMTClimateModelType.UM)
            XCTAssertEqual(meteorogram.startDate, self.startDate)
            XCTAssertEqual(meteorogram.images.count, expectedMoments.count)
            XCTAssertEqual(meteorogram.moments.count, expectedMoments.count)
            XCTAssertEqual(meteorogram.images.filter { $0 != nil }.count, expectedMoments.count)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testFetchOfFullMapMeteorogramWithoutStartDate()
    {
        forecastStore.result = .failure(.forecastStartDateNotFound)
        
        meteorogramStore.meteorogram(for: map) {
            guard case let .failure(error) = $0 else { XCTFail(); return }
            XCTAssertEqual(error, .meteorogramFetchFailure)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }

    func testFetchOfFullMapMeteorogramWithSomeErrors()
    {
        var index = 0
        let expectedMoments = map.forecastMoments(for: startDate)
        
        imageStore.mapResult = expectedMoments.map { _ in
            index += 1
            return index <= 9 ? failure : success
        }

        meteorogramStore.meteorogram(for: map) {
            guard case let .success(meteorogram) = $0 else { XCTFail(); return }
            XCTAssertEqual(meteorogram.model.type, MMTClimateModelType.UM)
            XCTAssertEqual(meteorogram.startDate, self.startDate)
            XCTAssertEqual(meteorogram.moments.count, expectedMoments.count)
            XCTAssertEqual(meteorogram.images.count, expectedMoments.count)
            XCTAssertEqual(meteorogram.images.filter { $0 != nil }.count, expectedMoments.count-9)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)
    }
    
    func testFetchOfFullMapMeteorogramWithTooManyErrors()
    {        
        var index = 0
        imageStore.mapResult = map.forecastMoments(for: startDate).map { _ in
            index += 1
            return index <= 12 ? failure : success
        }
        
        meteorogramStore.meteorogram(for: map) {
            guard case let .failure(error) = $0 else { XCTFail(); return }
            XCTAssertEqual(error, .meteorogramFetchFailure)
            self.completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 3)

    }
}
