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
import MeteoModel

@testable import MobileMeteo

class MMTMeteorogramPreviewShortcutTests : XCTestCase
{
    func testInitialization_UmModel()
    {
        let location = CLLocation(latitude: 2.2, longitude: 3.3)
        let city = MMTCityProt(name: "City", region: "Region", location: location)
        let shortcut = MMTMeteorogramShortcut(model: MMTUmClimateModel(), city: city)
        
        XCTAssertEqual(shortcut.identifier, "meteorogram/UM/City/Region/2.2:3.3")
        XCTAssertEqual(shortcut.city.name, "City")
        XCTAssertEqual(shortcut.city.region, "Region")
        XCTAssertEqual(shortcut.climateModel.type, .UM)
        XCTAssertEqual(shortcut.city.location.coordinate.latitude, 2.2)
        XCTAssertEqual(shortcut.city.location.coordinate.longitude, 3.3)
    }
    
    func testInitialization_CoampsModel()
    {
        let location = CLLocation(latitude: 1.2, longitude: 3.4)
        let city = MMTCityProt(name: "Kędzierzyn Koźle", region: "Warmińsko Mazurskie", location: location)
        let shortcut = MMTMeteorogramShortcut(model: MMTCoampsClimateModel(), city: city)
        
        XCTAssertEqual(shortcut.identifier, "meteorogram/COAMPS/Kędzierzyn Koźle/Warmińsko Mazurskie/1.2:3.4")
        XCTAssertEqual(shortcut.city.name, "Kędzierzyn Koźle")
        XCTAssertEqual(shortcut.city.region, "Warmińsko Mazurskie")
        XCTAssertEqual(shortcut.climateModel.type, .COAMPS)
        XCTAssertEqual(shortcut.city.location.coordinate.latitude, 1.2)
        XCTAssertEqual(shortcut.city.location.coordinate.longitude, 3.4)
    }

}
