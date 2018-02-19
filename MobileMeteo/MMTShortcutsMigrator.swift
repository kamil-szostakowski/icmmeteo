//
//  MMTShortcutsMigrator.swift
//  MobileMeteo
//
//  Created by szostakowskik on 16.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import CoreSpotlight

class MMTShortcutsMigrator: MMTVersionMigrator
{
    // MARK: Initializers
    var sequenceNumber: UInt = 1
    
    private var citiesStore: MMTCitiesStore
    private var spotlightRegister: MMTShortcutRegister
    private var quickActionsRegister: MMTShortcutRegister
    
    // MARK: Initializers
    convenience init ()
    {
        self.init(store: MMTCitiesStore(),
                  spotlight: CSSearchableIndex.default(),
                  quickActions: UIApplication.shared)
    }
    
    init(store: MMTCitiesStore, spotlight: MMTShortcutRegister, quickActions: MMTShortcutRegister)
    {
        spotlightRegister = spotlight
        quickActionsRegister = quickActions
        citiesStore = store
    }
    
    // MARK: Interface methods
    func migrate() throws
    {
        CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: nil)
        
        citiesStore.getAllCities {
            let modelUm = MMTUmClimateModel()
            
            $0.filter { $0.isFavourite == true }
                .map { MMTMeteorogramShortcut(model: modelUm, city: $0) }
                .forEach { spotlightRegister.register($0) }
            
            Array($0.filter { $0.isFavourite == true }.prefix(2))
                .map { MMTMeteorogramShortcut(model: modelUm, city: $0) }
                .forEach { quickActionsRegister.register($0) }
            
            quickActionsRegister.register(MMTDetailedMapShortcut(model: modelUm, map: .Precipitation))
        }
    }
}
