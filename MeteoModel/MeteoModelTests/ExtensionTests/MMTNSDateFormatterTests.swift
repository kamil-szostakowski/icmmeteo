//
//  MMTCategoryNSDateFormatterTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 31.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
@testable import MeteoModel

class MMTNSDateFormatterTests: XCTestCase
{
    // MARK: Test methods
    // TODO: Check behaviour of tests on different locales
    
    func testShortStyleFormatter()
    {
        let date = TT.getDate(2015, 7, 30, 23)
        XCTAssertEqual("2015.07.30", DateFormatter.shortDateOnlyStyle.string(from: date))
    }    
    
    func testUtcFormatterDateFromString()
    {
        let formatter = DateFormatter.utcFormatter
        let expectedDate = TT.getDate(2015, 7, 30, 23)
        
        XCTAssertEqual(expectedDate, formatter.date(from: "2015.07.30 23:00 UTC"))
        
    }
    
    func testUtcFormatterStringFromDate()
    {
        let formatter = DateFormatter.utcFormatter
        let expectedDateString = "2015.07.30 23:00 UTC"
        
        XCTAssertEqual(expectedDateString, formatter.string(from: TT.getDate(2015, 7, 30, 23)))
    }
}
