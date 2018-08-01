//
//  CSSearchableIndex.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 04.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
import CoreSpotlight
import MeteoModel

@testable import MobileMeteo

class CSSearchableIndexTests: XCTestCase
{
    // MARK: Test methods
    func testConversionOfMeteorogramPreviewShortcutToSearchableItem()
    {
        let city = MMTCityProt(name: "Lorem", region: "Ipsum", location: CLLocation(latitude: 2, longitude: 3))
        let shortcut = MMTMeteorogramShortcut(model: MMTUmClimateModel(), city: city)
        let item = CSSearchableIndex.default().convert(from: shortcut)
        
        XCTAssertEqual(item?.uniqueIdentifier, "meteorogram/UM/Lorem/Ipsum/2.0:3.0")
    }
    
    func testConversionOfUnsupportedShortcutToSearchableItem()
    {
        let shortcut = MMTDetailedMapShortcut(model: MMTUmClimateModel(), map: .Precipitation)
        XCTAssertNil(CSSearchableIndex.default().convert(from: shortcut))
    }
    
    func testConversionOfUserActivityToMeteorogramPreviewShortcut()
    {
        let
        activity = NSUserActivity(activityType: "com.apple.corespotlightitem")
        activity.userInfo = [CSSearchableItemActivityIdentifier: "meteorogram/UM/Lorem/Ipsum/2.0:3.0"]
        
        XCTAssertTrue(CSSearchableIndex.default().convert(from: activity) is MMTMeteorogramShortcut)
    }
    
    func testConversionOfInvalidUserActivityToShortcut()
    {
        let
        activity = NSUserActivity(activityType: "com.apple.corespotlightitem")
        activity.userInfo = [CSSearchableItemActivityIdentifier: "unsupported-shortcut"]
        
        XCTAssertNil(CSSearchableIndex.default().convert(from: activity))
    }
}
