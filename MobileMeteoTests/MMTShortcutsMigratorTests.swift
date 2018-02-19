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
    // MARK: Test methods
    func testShortcutsMigration()
    {
        class StubCitiesStore: MMTCitiesStore
        {
            let cities = [("Toruń",true), ("Bydgoszcz",true), ("Włocławek",true), ("Poznań",false), ("Konin",false)]
                .map { MMTCity(name: $0.0, favourite: $0.1) }
            
            override func getAllCities(_ completion: ([MMTCityProt]) -> Void) {
                completion(self.cities)
            }
        }
        
        let quickActions = StubRegister()
        let spotlight = StubRegister()
        
        let shortcutsMigrator = MMTShortcutsMigrator(store: StubCitiesStore(), spotlight: spotlight, quickActions: quickActions)
        try! shortcutsMigrator.migrate()
        
        XCTAssertEqual(quickActions.registrations, ["Toruń", "Bydgoszcz", "Precipitation"])
        XCTAssertEqual(spotlight.registrations, ["Toruń", "Bydgoszcz", "Włocławek"])
    }
}

// Helper extensions
fileprivate class StubRegister: MMTShortcutRegister
{
    var registrations: [String] = []
    
    func register(_ shortcut: MMTShortcut) {
        register(shortcut as? MMTMeteorogramShortcut)
        register(shortcut as? MMTDetailedMapShortcut)
    }
    
    func register(_ shortcut: MMTMeteorogramShortcut?) {
        if shortcut != nil { registrations.append(shortcut!.name) }
    }
    
    func register(_ shortcut: MMTDetailedMapShortcut?) {
        if shortcut != nil { registrations.append(shortcut!.detailedMap.rawValue) }
    }
    
    func unregister(_ shortcut: MMTShortcut) {}
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

