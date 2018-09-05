//
//  MMTCurrentLocationMeteorogramPreviewShortcutTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 15.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import MeteoModel

@testable import MobileMeteo

class MMTMeteorogramHereShortcutTests: XCTestCase
{
    func testInitialization_ModelUM()
    {
        let shortcut = MMTMeteorogramHereShortcut(model: MMTUmClimateModel())
        
        XCTAssertEqual(shortcut.identifier, "currentlocation")
        XCTAssertEqual(shortcut.climateModel.type, .UM)
    }
    
    func testInitialization_ModelCOAMPS()
    {
        let shortcut = MMTMeteorogramHereShortcut(model: MMTCoampsClimateModel())
        
        XCTAssertEqual(shortcut.identifier, "currentlocation")
        XCTAssertEqual(shortcut.climateModel.type, .COAMPS)
    }    
}
