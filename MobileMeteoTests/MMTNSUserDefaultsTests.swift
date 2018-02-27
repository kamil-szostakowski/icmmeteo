//
//  MMTNSUserDefaultsTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 16.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MobileMeteo

class MMTNSUserDefaultsTests: XCTestCase
{
    // MARK: Properties
    var defaults = UserDefaults.standard
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    // MARK: Test methods
    func testReadUninitializedValues()
    {
        XCTAssertNil(defaults.value(forKey: "Initialized"))
        XCTAssertNil(defaults.value(forKey: "SequenceNumber"))
        
        XCTAssertEqual(defaults.isAppInitialized, false)
        XCTAssertEqual(defaults.sequenceNumber, 0)
    }
    
    func testModificationOfProperties()
    {
        defaults.isAppInitialized = true
        defaults.sequenceNumber = 10
        
        XCTAssertEqual(defaults.isAppInitialized, true)
        XCTAssertEqual(defaults.sequenceNumber, 10)
    }
    
    func testCleanup()
    {
        defaults.isAppInitialized = true
        defaults.sequenceNumber = 10
        defaults.cleanup()
        
        XCTAssertNil(defaults.value(forKey: "Initialized"))
        XCTAssertNil(defaults.value(forKey: "SequenceNumber"))
    }
}
