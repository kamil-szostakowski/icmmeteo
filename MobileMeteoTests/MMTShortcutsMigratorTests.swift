//
//  MMTShortcutsMigratorTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 19.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MobileMeteo

class MMTShortcutsMigratorTests: XCTestCase
{
    // MARK: Properties
    fileprivate var quickActions: StubRegister!
    fileprivate var spotlight: StubRegister!
    fileprivate var shortcutsMigrator: MMTShortcutsMigrator!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        quickActions = StubRegister()
        spotlight = StubRegister()
        shortcutsMigrator = MMTShortcutsMigrator(store: StubCitiesStore(), spotlight: spotlight, quickActions: quickActions)
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
        let shortcut = MMTMeteorogramHereShortcut(model: MMTUmClimateModel(), locationService: MMTStubLocationService())
        
        quickActions.register(shortcut)
        try! shortcutsMigrator.migrate()
        
        XCTAssertTrue(quickActions.cleaned)
        XCTAssertEqual(quickActions.registrations, ["current-location", "Toruń", "Bydgoszcz", "Precipitation"])
        
        XCTAssertTrue(spotlight.cleaned)
        XCTAssertEqual(spotlight.registrations, ["Toruń", "Bydgoszcz", "Włocławek"])
    }
}

// MARK: Helper extensions
fileprivate class StubCitiesStore: MMTCitiesStore
{
    let cities = [("Toruń",true), ("Bydgoszcz",true), ("Włocławek",true), ("Poznań",false), ("Konin",false)]
        .map { MMTCity(name: $0.0, favourite: $0.1) }
    
    override func getAllCities(_ completion: ([MMTCityProt]) -> Void) {
        completion(self.cities)
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

fileprivate extension MMTCity
{
    convenience init(name: String, favourite: Bool)
    {
        let location = CLLocation(latitude: 0, longitude: 0)
        self.init(name: name, region: "\(name) region", location: location)
        isFavourite = favourite
    }
}

