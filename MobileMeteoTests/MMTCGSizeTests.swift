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
        XCTAssertEqual(CGSize(width: 540, height: 660), CGSize(meteorogram: .UM))
        XCTAssertEqual(CGSize(width: 660, height: 570), CGSize(meteorogram: .COAMPS))
        XCTAssertNil(CGSize(meteorogram: .WAM))
    }

    func testMeteorogramLegendSize()
    {
        XCTAssertEqual(CGSize(width: 280, height: 660), CGSize(meteorogramLegend: .UM))
        XCTAssertEqual(CGSize(width: 280, height: 570), CGSize(meteorogramLegend: .COAMPS))
        XCTAssertNil(CGSize(meteorogramLegend: .WAM))
    }

    func testDetailedMapMeteorogramSize()
    {
        XCTAssertEqual(CGSize(width: 669, height: 740), CGSize(map: .UM))
        XCTAssertEqual(CGSize(width: 590, height: 604), CGSize(map: .COAMPS))
        XCTAssertEqual(CGSize(width: 645, height: 702), CGSize(map: .WAM))
    }

    func testDetailedMapMeteorogramLegendSize()
    {
        XCTAssertEqual(CGSize(width: 128, height: 740), CGSize(mapLegend: .UM))
        XCTAssertEqual(CGSize(width: 128, height: 604), CGSize(mapLegend: .COAMPS))
        XCTAssertEqual(CGSize(width: 75, height: 702), CGSize(mapLegend: .WAM))
    }
}
