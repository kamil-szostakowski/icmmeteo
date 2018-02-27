//
//  MMT3DTouchTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 24.01.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation

@testable import MobileMeteo

extension MMTMeteorogramShortcut
{
    static var testInstance: MMTMeteorogramShortcut {
        let location = CLLocation(latitude: 2.2, longitude: 3.3)
        let city = MMTCity(name: "fake-city", region: "fake-region", location: location)
        
        return MMTMeteorogramShortcut(model: MMTUmClimateModel(), city: city)
    }
}

class MMTMeteorogramPreviewShortcutConversion_3DTouchTests: XCTestCase
{
    var userInfo: [String : Any] = [
        "latitude": 2.2,
        "longitude": 3.3,
        "city-name": "fake-city",
        "city-region": "fake-region",
        "climate-model": "UM"
    ]
    
    var shortcut: MMTMeteorogramShortcut? {
        return MMTMeteorogramShortcut(shortcut: UIApplicationShortcutItem(type: "", localizedTitle: "", localizedSubtitle: "", icon: nil, userInfo: userInfo))
    }
    
    // MARK: Test methods
    func testConversionToUIApplicationShortcutItem()
    {        
        let item = UIApplicationShortcutItem(shortcut: MMTMeteorogramShortcut.testInstance)
        
        XCTAssertEqual(item.type, "meteorogram-UM-2.2:3.3")
        XCTAssertEqual(item.localizedTitle, "fake-city")
        XCTAssertEqual(item.localizedSubtitle, "fake-region")
        XCTAssertEqual(item.icon, UIApplicationShortcutIcon(type: .favorite))
            
        XCTAssertEqual(item.userInfo?["latitude"] as? CLLocationDegrees, 2.2)
        XCTAssertEqual(item.userInfo?["longitude"] as? CLLocationDegrees, 3.3)
        XCTAssertEqual(item.userInfo?["city-name"] as? String, "fake-city")
        XCTAssertEqual(item.userInfo?["city-region"] as? String, "fake-region")
        XCTAssertEqual(item.userInfo?["climate-model"] as? String, "UM")
    }
    
    func testConversionToMeteorogramPreviewShortcut()
    {
        XCTAssertEqual(shortcut?.location.coordinate.latitude, 2.2)
        XCTAssertEqual(shortcut?.location.coordinate.longitude, 3.3)
        XCTAssertEqual(shortcut?.name, "fake-city")
        XCTAssertEqual(shortcut?.region, "fake-region")
        XCTAssertEqual(shortcut?.climateModelType, "UM")
    }
    
    func testConversionToMeteorogramPreviewShortcut_NoLatitude()
    {
        userInfo.removeValue(forKey: "latitude")
        XCTAssertNil(shortcut)
    }
    
    func testConversionToMeteorogramPreviewShortcut_NoLongitude()
    {
        userInfo.removeValue(forKey: "longitude")
        XCTAssertNil(shortcut)
    }
    
    func testConversionToMeteorogramPreviewShortcut_NoCity()
    {
        userInfo.removeValue(forKey: "city-name")
        XCTAssertNil(shortcut)
    }
    
    func testConversionToMeteorogramPreviewShortcut_NoRegion()
    {
        userInfo.removeValue(forKey: "city-region")
        XCTAssertNil(shortcut)
    }
    
    func testConversionToMeteorogramPreviewShortcut_NoClimateModel()
    {
        userInfo.removeValue(forKey: "climate-model")
        XCTAssertNil(shortcut)
    }
    
    func testConversionToMeteorogramPreviewShortcut_InvalidClimateModel()
    {
        userInfo["longitude"] = "lorem ipsum"
        XCTAssertNil(shortcut)
    }
}
