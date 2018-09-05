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
import MeteoModel

@testable import MobileMeteo

extension MMTMeteorogramShortcut
{
    static var testInstance: MMTMeteorogramShortcut
    {
        let location = CLLocation(latitude: 2.2, longitude: 3.3)
        let city = MMTCityProt(name: "fakecity", region: "fakeregion", location: location)
        
        return MMTMeteorogramShortcut(model: MMTUmClimateModel(), city: city)
    }
}

class MMTMeteorogramPreviewShortcutConversion_3DTouchTests: XCTestCase
{
    var userInfo: [String : Any] = [
        "latitude": 2.2,
        "longitude": 3.3,
        "city-name": "fakecity",
        "city-region": "fakeregion",
        "climate-model": "UM"
    ]
    
    var shortcut: MMTMeteorogramShortcut? {
        return MMTMeteorogramShortcut(shortcut: UIApplicationShortcutItem(type: "", localizedTitle: "", localizedSubtitle: "", icon: nil, userInfo: userInfo))
    }
    
    // MARK: Test methods
    func testConversionToUIApplicationShortcutItem()
    {        
        let item = UIApplicationShortcutItem(shortcut: MMTMeteorogramShortcut.testInstance)
        
        XCTAssertEqual(item.type, "meteorogram/UM/fakecity/fakeregion/2.2:3.3")
        XCTAssertEqual(item.localizedTitle, "fakecity")
        XCTAssertEqual(item.localizedSubtitle, "fakeregion")
        XCTAssertEqual(item.icon, UIApplicationShortcutIcon(type: .favorite))
            
        XCTAssertEqual(item.userInfo?["latitude"] as? CLLocationDegrees, 2.2)
        XCTAssertEqual(item.userInfo?["longitude"] as? CLLocationDegrees, 3.3)
        XCTAssertEqual(item.userInfo?["city-name"] as? String, "fakecity")
        XCTAssertEqual(item.userInfo?["city-region"] as? String, "fakeregion")
        XCTAssertEqual(item.userInfo?["climate-model"] as? String, "UM")
    }
    
    func testConversionToMeteorogramPreviewShortcut()
    {
        XCTAssertEqual(shortcut?.city.location.coordinate.latitude, 2.2)
        XCTAssertEqual(shortcut?.city.location.coordinate.longitude, 3.3)
        XCTAssertEqual(shortcut?.city.name, "fakecity")
        XCTAssertEqual(shortcut?.city.region, "fakeregion")
        XCTAssertEqual(shortcut?.climateModel.type, .UM)
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
