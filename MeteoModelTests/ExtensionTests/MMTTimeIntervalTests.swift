//
//  MMTTimeIntervalTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 05.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTTimeIntervalTests: XCTestCase
{
    
    func testMinutesConversion()
    {
        XCTAssertEqual(TimeInterval(minutes: 10), 600)
        XCTAssertEqual(TimeInterval(minutes: -10), -600)
        XCTAssertEqual(TimeInterval(minutes: 0), 0)
    }
    
    func testHoursConversion()
    {
        XCTAssertEqual(TimeInterval(hours: 10), 36000)
        XCTAssertEqual(TimeInterval(hours: -10), -36000)
        XCTAssertEqual(TimeInterval(hours: 0), 0)    }
    
}
