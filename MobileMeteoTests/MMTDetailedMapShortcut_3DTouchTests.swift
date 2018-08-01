//
//  MMTDetailedMapPreviewShortcut+3DTouchTests.swift
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

class MMTDetailedMapPreviewShortcut_3DTouchTests : XCTestCase
{
    // MARK: Properties
    var type = "map/UM/Precipitation"
    var userInfo: [String:Any] = [
        "climate-model": "UM",
        "detailed-map": "Precipitation"
    ]
    
    var shortcutItem: UIApplicationShortcutItem {
        return UIApplicationShortcutItem(type: type, localizedTitle: "", localizedSubtitle: "", icon: nil, userInfo: userInfo)
    }
    
    // MARK: Test methods
    func testConversionToUIApplicationShortcutItem()
    {
        let shortcut = MMTDetailedMapShortcut(model: MMTUmClimateModel(), map: .Precipitation)
        let item = UIApplicationShortcutItem(shortcut: shortcut)
        
        XCTAssertEqual(item.type, type)
        XCTAssertEqual(item.userInfo?["climate-model"] as? String, "UM")
        XCTAssertEqual(item.userInfo?["detailed-map"] as? String, "Precipitation")
        XCTAssertEqual(item.icon, UIApplicationShortcutIcon(type: .cloud))
    }
    
    func testConversionToDetailedMapPreviewShortcut()
    {
        let shortcut = MMTDetailedMapShortcut(shortcut: shortcutItem)
        
        XCTAssertTrue(shortcut?.climateModel is MMTUmClimateModel)
        XCTAssertEqual(shortcut?.detailedMap, .Precipitation)
    }
    
    func testConversionToDetailedMapPreviewShortcut_NoClimateModel()
    {
        userInfo.removeValue(forKey: "climate-model")
        XCTAssertNil(MMTDetailedMapShortcut(shortcut: shortcutItem))
        
        userInfo["climate-model"] = 10
        XCTAssertNil(MMTDetailedMapShortcut(shortcut: shortcutItem))
    }
    
    func testConversionToDetailedMapPreviewShortcut_NoDetailedMap()
    {
        userInfo.removeValue(forKey: "detailed-map")
        XCTAssertNil(MMTDetailedMapShortcut(shortcut: shortcutItem))
        
        userInfo["detailed-map"] = 10
        XCTAssertNil(MMTDetailedMapShortcut(shortcut: shortcutItem))
    }
}
