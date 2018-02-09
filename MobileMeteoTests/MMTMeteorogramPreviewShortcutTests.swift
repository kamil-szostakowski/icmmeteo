//
//  MMTMeteorogramPreviewShortcutTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 29.01.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation

@testable import MobileMeteo

class MMTMeteorogramPreviewShortcutTests : XCTestCase
{
    func testInitialization_UmModel()
    {
        let location = CLLocation(latitude: 2.2, longitude: 3.3)
        let city = MMTCity(name: "City", region: "Region", location: location)
        let shortcut = MMTMeteorogramPreviewShortcut(model: MMTUmClimateModel(), city: city)
        
        XCTAssertEqual(shortcut.identifier, "meteorogram-UM-2.2:3.3")
        XCTAssertEqual(shortcut.name, "City")
        XCTAssertEqual(shortcut.region, "Region")
        XCTAssertEqual(shortcut.climateModelType, "UM")
        XCTAssertEqual(shortcut.location.coordinate.latitude, 2.2)
        XCTAssertEqual(shortcut.location.coordinate.longitude, 3.3)
    }
    
    func testInitialization_CoampsModel()
    {
        let location = CLLocation(latitude: 1.2, longitude: 3.4)
        let city = MMTCity(name: "City", region: "Region", location: location)
        let shortcut = MMTMeteorogramPreviewShortcut(model: MMTCoampsClimateModel(), city: city)
        
        XCTAssertEqual(shortcut.identifier, "meteorogram-COAMPS-1.2:3.4")
        XCTAssertEqual(shortcut.name, "City")
        XCTAssertEqual(shortcut.region, "Region")
        XCTAssertEqual(shortcut.climateModelType, "COAMPS")
        XCTAssertEqual(shortcut.location.coordinate.latitude, 1.2)
        XCTAssertEqual(shortcut.location.coordinate.longitude, 3.4)
    }

}
