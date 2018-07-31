//
//  MMTShortcutsMigratorTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 19.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
import MeteoModel
@testable import MobileMeteo

class MMTShortcutsMigratorTests: XCTestCase
{
    // MARK: Properties
    fileprivate var quickActions: StubRegister!
    fileprivate var spotlight: StubRegister!
    fileprivate var locationService: MMTStubLocationService!
    fileprivate var shortcutsMigrator: MMTShortcutsMigrator!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        let cities = [("Toruń",true), ("Bydgoszcz",true), ("Włocławek",true), ("Poznań",false), ("Konin",false)]
        
        quickActions = StubRegister()
        spotlight = StubRegister()
        locationService = MMTStubLocationService()
        
        shortcutsMigrator = MMTShortcutsMigrator(store: StubCitiesStore(cities.map { MMTCityProt($0) }), spotlight: spotlight, quickActions: quickActions, locationService: locationService)
    }

    override func tearDown()
    {
        super.tearDown()
        quickActions = nil
        spotlight = nil
        shortcutsMigrator = nil
    }
    
    // MARK: Test methods
    func testShortcutsMigration_NoCurrentLocation()
    {
        try! shortcutsMigrator.migrate()
        
        XCTAssertTrue(quickActions.cleaned)
        XCTAssertEqual(quickActions.registrations, ["Toruń", "Bydgoszcz", "Precipitation"])
        
        XCTAssertTrue(spotlight.cleaned)
        XCTAssertEqual(spotlight.registrations, ["Toruń", "Bydgoszcz", "Włocławek"])
    }
    
    func testShortcutsMigration_WithCurrentLocation()
    {
        locationService.location = MMTCityProt(name: "Lorem", region: "", location: CLLocation(latitude: 1, longitude: 1))
        try! shortcutsMigrator.migrate()
        
        XCTAssertTrue(quickActions.cleaned)
        XCTAssertEqual(quickActions.registrations, ["current-location", "Toruń", "Bydgoszcz", "Precipitation"])
        
        XCTAssertTrue(spotlight.cleaned)
        XCTAssertEqual(spotlight.registrations, ["Toruń", "Bydgoszcz", "Włocławek"])
    }
}

// MARK: Helper extensions
extension MMTCityProt
{
    init(_ data: (String, Bool))
    {
        self.init(name: data.0, region: "\(data.0) region", location: CLLocation(latitude: 0, longitude: 0))
        self.isFavourite = data.1
    }
}


fileprivate class StubRegister: MMTShortcutRegister
{
    var registrations: [String] = []
    var cleaned: Bool = false
    
    func register(_ shortcut: MMTShortcut)
    {
        if let short = shortcut as? MMTDetailedMapShortcut {
            registrations.append(short.detailedMap.rawValue)
        } else if let short = shortcut as? MMTMeteorogramHereShortcut {
            registrations.append(short.identifier)
        } else if let short = shortcut as? MMTMeteorogramShortcut {
            registrations.append(short.name)
        }
    }
        
    func unregister(_ shortcut: MMTShortcut) {}
    
    func unregisterAll() {
        cleaned = true
    }
}
