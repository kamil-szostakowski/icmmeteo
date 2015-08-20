//
//  MMTWamMeteorogramStoreTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import MobileMeteo

class MMTWamModelStoreTests: XCTestCase
{
    var store: MMTWamModelStore!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        store = MMTWamModelStore()
    }
    
    override func tearDown()
    {
        store = nil
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func testForecastLenght()
    {
        XCTAssertEqual(84, store.forecastLength)
    }
    
    func testStartForecastDate()
    {
        let expectedDate = TT.utcFormatter.dateFromString("2015-03-11T00:00")!
        let date = TT.localFormatter.dateFromString("2015-03-12T01:34")!
        
        XCTAssertEqual(expectedDate, store.forecastStartDateForDate(date))
    }
}