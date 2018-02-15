//
//  MMTMeteorogramPreviewShortcutConversion_SpotlightTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 28.01.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
import CoreSpotlight

@testable import MobileMeteo

class MMTMeteorogramPreviewShortcutConversion_SpotlightTests : XCTestCase
{
    // MARK: Test methods
    func testConversionToCSSearchableItem()
    {
        let shortcut = MMTMeteorogramShortcut.testInstance
        let item = CSSearchableItem(shortcut: shortcut)
        
        XCTAssertEqual(item.uniqueIdentifier, "meteorogram-UM-2.2:3.3")
        XCTAssertEqual(item.domainIdentifier, MMTActivityTypeDisplayModelUm)
        XCTAssertEqual(item.attributeSet.keywords!, ["Pogoda", "Model UM", "fake-city"])
        XCTAssertEqual(item.attributeSet.displayName, "fake-city, fake-region")
        XCTAssertEqual(item.attributeSet.contentDescription, "Prognoza pogody w modelu UM\nSiatka: 4km. Długość prognozy 60h")
    }
    
    func testConversionToMeteorogramPreviewShortcut()
    {
        let activity = userActivity(identifier: "meteorogram-UM-2.2:3.3")
        let shortcut = MMTMeteorogramShortcut(userActivity: activity)
        
        XCTAssertEqual(shortcut?.identifier, "meteorogram-UM-2.2:3.3")
        XCTAssertEqual(shortcut?.location.coordinate.latitude, 2.2)
        XCTAssertEqual(shortcut?.location.coordinate.longitude, 3.3)
        XCTAssertEqual(shortcut?.climateModelType, "UM")
        XCTAssertEqual(shortcut?.name, "")
        XCTAssertEqual(shortcut?.region, "")
    }
    
    func testConversionToMeteorogramPreviewShortcut_NoIdentifier()
    {
        let activity = userActivity(identifier: nil)
        XCTAssertNil(MMTMeteorogramShortcut(userActivity: activity))        
    }
    
    func testConversionToMeteorogramPreviewShortcut_NoLocation()
    {
        let activity1 = userActivity(identifier: "meteorogram-UM")
        XCTAssertNil(MMTMeteorogramShortcut(userActivity: activity1))
        
        let activity2 = userActivity(identifier: "meteorogram-UM-a:b")
        XCTAssertNil(MMTMeteorogramShortcut(userActivity: activity2))
        
        let activity3 = userActivity(identifier: "meteorogram-UM-2.2:b")
        XCTAssertNil(MMTMeteorogramShortcut(userActivity: activity3))
    }

    func testConversionToMeteorogramPreviewShortcut_NoModel()
    {
        let activity = userActivity(identifier: "meteorogram-2.2:3.3")
        XCTAssertNil(MMTMeteorogramShortcut(userActivity: activity))
    }

    // MARK: Helper methods
    func userActivity(identifier: String?) -> NSUserActivity
    {
        let activity = NSUserActivity(activityType: "com.apple.corespotlightitem")
        if let id = identifier {
            activity.userInfo = [CSSearchableItemActivityIdentifier: id]
        }
        
        return activity
    }

}
