//
//  MMTMeteorogramHereShortcutConversion_3DTouchTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 01.08.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import MeteoModel
@testable import MobileMeteo

class MMTMeteorogramHereShortcutConversion_3DTouchTests: XCTestCase
{
    // MARK: Properties
    var service = MMTStubLocationService()
    
    // MARK: Test methods
    func testConversionFromShortcut()
    {
        let shortcut = MMTMeteorogramHereShortcut(model: MMTUmClimateModel())
        
        let item = UIApplicationShortcutItem(shortcut: shortcut)
        
        XCTAssertEqual(item.icon, UIApplicationShortcutIcon(type: .location))
        XCTAssertEqual(item.userInfo!["climate-model"] as? String, "UM")
        XCTAssertEqual(item.type, "currentlocation")
    }
    
    func testConversionFromShortcutItem()
    {
        let item = UIApplicationShortcutItem(type: "currentlocation", localizedTitle: "", localizedSubtitle: nil, icon:nil, userInfo: ["climate-model": "UM"])
        
        let shortcut = MMTMeteorogramHereShortcut(shortcut: item)
        
        XCTAssertEqual(shortcut?.identifier, "currentlocation")
        XCTAssertEqual(shortcut?.climateModel.type, .UM)
    }
    
    func testConversionFromShortcutItem_NoModel()
    {
        let item = UIApplicationShortcutItem(type: "currentlocation", localizedTitle: "", localizedSubtitle: nil, icon:nil, userInfo: nil)        
        
        XCTAssertNil(MMTMeteorogramHereShortcut(shortcut: item))
    }
    
    func testConversionFromShortcutItem_WrongType()
    {
        let item = UIApplicationShortcutItem(type: "type", localizedTitle: "", localizedSubtitle: nil, icon:nil, userInfo: ["climate-model": "UM"])
        
        XCTAssertNil(MMTMeteorogramHereShortcut(shortcut: item))
    }
}
