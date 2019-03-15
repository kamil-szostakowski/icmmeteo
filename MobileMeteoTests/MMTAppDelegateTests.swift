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
        
        appDelegate.factory = mockFactory
        appDelegate.window = UIApplication.shared.keyWindow
    }

    // MARK: Test methods
    func testBackgroundFetch()
    {
        mockFactory.forecastUpdateResult = .noData
        verifyBackgroundFetchStatus(.noData)
        
        mockFactory.forecastUpdateResult = .newData
        verifyBackgroundFetchStatus(.newData)
        
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
