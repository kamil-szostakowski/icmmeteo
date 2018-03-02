//
//  MMTClimateModelTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 14.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
@testable import MeteoModel

class MMTClimateModelTests: XCTestCase
{
    func testModelFromTypeInitialization()
    {
        XCTAssertTrue(MMTClimateModelType.UM.model is MMTUmClimateModel)
        XCTAssertTrue(MMTClimateModelType.COAMPS.model is MMTCoampsClimateModel)
        XCTAssertTrue(MMTClimateModelType.WAM.model is MMTWamClimateModel)
    }
}
