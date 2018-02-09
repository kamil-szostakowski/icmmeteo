//
//  UIApplicationTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 29.01.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation

@testable import MobileMeteo

class UIApplicationTests : XCTestCase
{
    var meteorogramShortcut: MMTMeteorogramPreviewShortcut!
    var currentLocationShortcut: MMTCurrentLocationMeteorogramPreviewShortcut!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        UIApplication.shared.shortcutItems?.removeAll()
        
        let city = MMTCity(name: "Lorem", region: "Ipsum", location: CLLocation(latitude: 2, longitude: 2))
        meteorogramShortcut = MMTMeteorogramPreviewShortcut(model: MMTUmClimateModel(), city: city)
        currentLocationShortcut = MMTCurrentLocationMeteorogramPreviewShortcut(model: MMTUmClimateModel())
    }
    
    override func tearDown()
    {
        super.tearDown()
        meteorogramShortcut = nil
        currentLocationShortcut = nil
    }
    
    // MARK: Test methods
    func testConversionOfMeteorogramPreviewShortcutToApplicationShortcutItem()
    {
        let item = UIApplication.shared.convert(from: MMTMeteorogramPreviewShortcut.testInstance)!
        XCTAssertEqual(item.type, "meteorogram-UM-2.2:3.3")
    }
    
    func testConversionOfDetailedMapPreviewShortcutToApplicationShortcutItem()
    {
        let shortcut = MMTDetailedMapPreviewShortcut(model: MMTUmClimateModel(), map: .Precipitation)
        let item = UIApplication.shared.convert(from: shortcut)!
        
        XCTAssertEqual(item.type, "map-UM-Precipitation")
    }
    
    func testConversionOfCurrentLocationMeteorogramPreviewShortcutToApplicationShortcutItem()
    {
        let shortcut = MMTCurrentLocationMeteorogramPreviewShortcut(model: MMTUmClimateModel())
        let item = UIApplication.shared.convert(from: shortcut)!
        
        XCTAssertEqual(item.type, "current-location")
    }
    
    func testConversionOfUnsupportedShortcutToApplicationShortcutItem()
    {
        XCTAssertNil(UIApplication.shared.convert(from: MMTUnsupportedShortcut()))
    }
    
    func testConversionOfApplicationShortcutItemToDetailedMapPreviewShortcut()
    {
        let item = UIApplicationShortcutItem(type: "map-UM-Precipitation", localizedTitle: "", localizedSubtitle: "", icon: nil, userInfo: ["climate-model" : "UM", "detailed-map" : "Precipitation"])
        
        XCTAssertTrue(UIApplication.shared.convert(from: item) is MMTDetailedMapPreviewShortcut)
    }
    
    func testConversionOfApplicationShortcutItemToMeteorogramPreviewShortcut()
    {
        let item = UIApplicationShortcutItem(type: "meteorogram-UM-2.2:3.3", localizedTitle: "", localizedSubtitle: "", icon: nil, userInfo: ["latitude" : 2.2,                                                                                                                                                                 "longitude" : 3.3,                                                                                                                                                          "city-name" : "Lorem",                                                                                                                                                          "city-region" : "Ipsum",                                                                                                                                                          "climate-model" : "UM"])
        
        XCTAssertTrue(UIApplication.shared.convert(from: item) is MMTMeteorogramPreviewShortcut)
    }
    
    func testConversionOfApplicationShortcutItemToCurrentLocationMeteorogramPreviewShortcut()
    {
        let item = UIApplicationShortcutItem(type: "current-location", localizedTitle: "", localizedSubtitle: "", icon: nil, userInfo: ["latitude" : 0,                                                                                                                                                                 "longitude" : 0,                                                                                                                                                          "city-name" : "",                                                                                                                                                          "city-region" : "",                                                                                                                                                          "climate-model" : "UM"])
        
        XCTAssertTrue(UIApplication.shared.convert(from: item) is MMTCurrentLocationMeteorogramPreviewShortcut)
    }
    
    func testConversionOfApplicationShortcutItemToUnsupportedShortcut()
    {
        let item = UIApplicationShortcutItem(type: "unsupported-type", localizedTitle: "")
        XCTAssertNil(UIApplication.shared.convert(from: item))
    }
    
    func testRegisterNormalShortcut()
    {
        UIApplication.shared.register(meteorogramShortcut)
        
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 1)
        XCTAssertEqual(UIApplication.shared.shortcutItems?[0].type, "meteorogram-UM-2.0:2.0")
    }
    
    func testRegisterCurrentLocationShortcut()
    {
        UIApplication.shared.register(currentLocationShortcut)
        UIApplication.shared.register(meteorogramShortcut)
        
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 2)
        XCTAssertEqual(UIApplication.shared.shortcutItems?[0].type, "meteorogram-UM-2.0:2.0")
        XCTAssertEqual(UIApplication.shared.shortcutItems?[1].type, "current-location")
    }
    
    func testRegisterAlreadyRegisteredShortcut()
    {
        UIApplication.shared.register(meteorogramShortcut)
        UIApplication.shared.register(meteorogramShortcut)
        
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 1)
        XCTAssertEqual(UIApplication.shared.shortcutItems?[0].type, "meteorogram-UM-2.0:2.0")
    }
    
    func testRegisterUnsupportedShortcut()
    {
        UIApplication.shared.register(MMTUnsupportedShortcut())
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 0)
    }
    
    func testUnregisterShortcut()
    {
        UIApplication.shared.register(meteorogramShortcut)
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 1)
        
        UIApplication.shared.unregister(meteorogramShortcut)
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 0)
    }
    
    func testUnregisterNotRegisteredShortcut()
    {
        UIApplication.shared.register(meteorogramShortcut)
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 1)
        
        UIApplication.shared.unregister(currentLocationShortcut)
        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 1)

    }
}

fileprivate class MMTUnsupportedShortcut: MMTShortcut
{
    var identifier: String = ""
    
    func execute(using tabbar: MMTTabBarController, completion: MMTCompletion?) { }
}
