//
//  MMTCategoryNSDateFormatterTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 31.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import MobileMeteo

class MMTCategoryNSDateFormatterTests: XCTestCase
{
    // MARK: Test methods
    
    func testShortStyleFormatter()
    {
        let date = TT.getDate(2015, 7, 30, 23)
        XCTAssertEqual("30.07.2015", NSDateFormatter.shortStyle.stringFromDate(date))
    }
    
    func testMomentStyleFormatter()
    {
        let date1 = TT.getDate(2015, 7, 30, 6)
        XCTAssertEqual("t0 +006h", NSDateFormatter.momentStyle.stringFromDate(date1))
        
        let date2 = TT.getDate(2015, 7, 30, 12)
        XCTAssertEqual("t0 +012h", NSDateFormatter.momentStyle.stringFromDate(date2))
    }
}