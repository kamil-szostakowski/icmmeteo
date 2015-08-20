//
//  MMTWamModelMeteorogramQueryTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import MobileMeteo

class MMTWamModelMeteorogramQueryTests: XCTestCase
{
    // MARK: Test methods
    
    func testTZeroDate()
    {
        let date = TT.utcFormatter.dateFromString("2015-08-05T00:00")!
        let query = MMTWamModelMeteorogramQuery(category: .TideHeight, tZero: date, tZeroPlus: 3)
        
        XCTAssertEqual(date, query.tZero)
    }
    
    func testTZeroPlusValue()
    {
        let query = MMTWamModelMeteorogramQuery(category: .TideHeight, tZero: NSDate(), tZeroPlus: 3)
        
        XCTAssertEqual(3, query.tZeroPlus)
    }
    
    func testWamCategory()
    {
        let query1 = MMTWamModelMeteorogramQuery(category: .TideHeight, tZero: NSDate(), tZeroPlus: 3)
        XCTAssertEqual(.TideHeight, query1.category)
        
        let query2 = MMTWamModelMeteorogramQuery(category: .AvgTidePeriod, tZero: NSDate(), tZeroPlus: 3)
        XCTAssertEqual(.AvgTidePeriod, query2.category)
    }
}