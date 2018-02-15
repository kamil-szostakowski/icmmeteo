//
//  MMTCurrentLocationMeteorogramPreviewShortcutTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 15.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation

@testable import MobileMeteo

class MMTCurrentLocationMeteorogramPreviewShortcutTests: XCTestCase
{
    func testInitialization_ModelUM()
    {
        let shortcut = MMTCurrentLocationMeteorogramPreviewShortcut(model: MMTUmClimateModel(), locationService: MMTStubLocationService())
        
        XCTAssertEqual(shortcut.identifier, "current-location")
        XCTAssertEqual(shortcut.name, MMTLocalizedString("forecast.here"))
        XCTAssertEqual(shortcut.region, "")
        XCTAssertEqual(shortcut.climateModelType, "UM")
        XCTAssertEqual(shortcut.location.coordinate.latitude, 0.0)
        XCTAssertEqual(shortcut.location.coordinate.longitude, 0.0)
    }
    
    func testInitialization_ModelCOAMPS()
    {
        let shortcut = MMTCurrentLocationMeteorogramPreviewShortcut(model: MMTCoampsClimateModel(), locationService: MMTStubLocationService())
        
        XCTAssertEqual(shortcut.identifier, "current-location")
        XCTAssertEqual(shortcut.name, MMTLocalizedString("forecast.here"))
        XCTAssertEqual(shortcut.region, "")
        XCTAssertEqual(shortcut.climateModelType, "COAMPS")
        XCTAssertEqual(shortcut.location.coordinate.latitude, 0.0)
        XCTAssertEqual(shortcut.location.coordinate.longitude, 0.0)
    }
}
