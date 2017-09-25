//
//  MMTCategoryCGSizeTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 30/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MobileMeteo

class MMTCGSizeTests: XCTestCase
{
    func testMeteorogramSize()
    {        
        XCTAssertEqual(CGSize(width: 540, height: 660), CGSize(forMeteorogramOfModel: .UM))
        XCTAssertEqual(CGSize(width: 660, height: 570), CGSize(forMeteorogramOfModel: .COAMPS))
        XCTAssertNil(CGSize(forMeteorogramOfModel: .WAM))
    }

    func testMeteorogramLegendSize()
    {
        XCTAssertEqual(CGSize(width: 280, height: 660), CGSize(forMeteorogramLegendOfModel: .UM))
        XCTAssertEqual(CGSize(width: 280, height: 570), CGSize(forMeteorogramLegendOfModel: .COAMPS))
        XCTAssertNil(CGSize(forMeteorogramLegendOfModel: .WAM))
    }

    func testDetailedMapMeteorogramSize()
    {
        XCTAssertEqual(CGSize(width: 669, height: 740), CGSize(forDetailedMapOfModel: .UM))
        XCTAssertEqual(CGSize(width: 590, height: 604), CGSize(forDetailedMapOfModel: .COAMPS))
        XCTAssertEqual(CGSize(width: 645, height: 702), CGSize(forDetailedMapOfModel: .WAM))
    }

    func testDetailedMapMeteorogramLegendSize()
    {
        XCTAssertEqual(CGSize(width: 128, height: 740), CGSize(forDetailedMapLegendOfModel: .UM))
        XCTAssertEqual(CGSize(width: 128, height: 604), CGSize(forDetailedMapLegendOfModel: .COAMPS))
        XCTAssertEqual(CGSize(width: 75, height: 702), CGSize(forDetailedMapLegendOfModel: .WAM))
    }
}
