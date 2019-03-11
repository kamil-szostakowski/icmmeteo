//
//  MMTAppDelegateTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 09/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MobileMeteo
@testable import MeteoModel

class MMTAppDelegateTests: XCTestCase
{
    var mockFactory = MMTMockFactory()
    var appDelegate = MMTAppDelegate()
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        let city = MMTCityProt(name: "Lorem", region: "", location: CLLocation())
        mockFactory.cachedMeteorogram = MMTMeteorogram(model: MMTUmClimateModel(), city:city)
        
        appDelegate.factory = mockFactory
        appDelegate.window = UIApplication.shared.keyWindow
    }

    // MARK: Test methods
    func testBackgroundFetchWhenCacheIsEmpty()
    {
        mockFactory.forecastUpdateResult = .noData
        mockFactory.cachedMeteorogram = nil
        verifyBackgroundFetchStatus(.noData)
    }
    
    func testBackgroundFetchWhenNoData()
    {
        mockFactory.forecastUpdateResult = .noData
        verifyBackgroundFetchStatus(.noData)
    }
    
    func testBackgroundFetchWhenNewData()
    {
        mockFactory.forecastUpdateResult = .newData
        verifyBackgroundFetchStatus(.newData)
    }
    
    func testBackgroundFetchWhenFailure()
    {
        mockFactory.forecastUpdateResult = .failed
        verifyBackgroundFetchStatus(.failed)
    }
}

extension MMTAppDelegateTests
{
    func verifyBackgroundFetchStatus(_ status: UIBackgroundFetchResult)
    {
        let completion = expectation(description: "Completion expectation")
        
        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        appDelegate.application(UIApplication.shared) {
            XCTAssertEqual($0, status)
            completion.fulfill()
        }
        
        wait(for: [completion], timeout: 2)
    }
}
