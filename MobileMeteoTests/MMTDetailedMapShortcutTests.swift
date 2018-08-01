//
//  MMTDetailedMapPreviewShortcutTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 29.01.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
import MeteoModel

@testable import MobileMeteo

class MMTDetailedMapPreviewShortcutTests : XCTestCase
{
    func testInitialization_ModelUM()
    {
        let model = MMTUmClimateModel()
        let shortcut = MMTDetailedMapShortcut(model: model, map: .AverageTidePeriod)
        
        XCTAssertEqual(shortcut.climateModel.type, .UM)
        XCTAssertEqual(shortcut.detailedMap, .AverageTidePeriod)
        XCTAssertEqual(shortcut.identifier, "map/UM/AverageTidePeriod")
    }
    
    func testInitialization_ModelCOAMPS()
    {
        let model = MMTCoampsClimateModel()
        let shortcut = MMTDetailedMapShortcut(model: model, map: .VeryLowClouds)
        
        XCTAssertEqual(shortcut.climateModel.type, .COAMPS)
        XCTAssertEqual(shortcut.detailedMap, .VeryLowClouds)
        XCTAssertEqual(shortcut.identifier, "map/COAMPS/VeryLowClouds")
    }
}
