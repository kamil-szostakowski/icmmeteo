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
    private var locationService: MMTLocationService
    
    // MARK: Initializers
    convenience init ()
    {
        self.init(store: MMTCitiesStore(), spotlight: CSSearchableIndex.default(), quickActions: UIApplication.shared, locationService: UIApplication.shared.locationService!)
    }
    
    init(store: MMTCitiesStore, spotlight: MMTShortcutRegister, quickActions: MMTShortcutRegister, locationService: MMTLocationService)
    {
        self.spotlightRegister = spotlight
        self.quickActionsRegister = quickActions
        self.citiesStore = store
        self.locationService = locationService
    }
    
    // MARK: Interface methods
    func migrate() throws
    {
        citiesStore.getAllCities {
            spotlightRegister.unregisterAll()
            quickActionsRegister.unregisterAll()
            
            // Spotlight index migration
            $0.filter { $0.isFavourite == true }
                .map { MMTMeteorogramShortcut(model: MMTUmClimateModel(), city: $0) }
                .forEach { spotlightRegister.register($0) }
            
            if self.locationService.currentLocation != nil {
                let shortcut = MMTMeteorogramHereShortcut(model: MMTUmClimateModel(), locationService: self.locationService)
                quickActionsRegister.register(shortcut)
            }
            
            // 3D Touch quic actions migration
            $0.filter { $0.isFavourite == true }
                .prefix(MMTMeteorogramShortcutsLimit)
                .map { MMTMeteorogramShortcut(model: MMTUmClimateModel(), city: $0) }
                .forEach { quickActionsRegister.register($0) }
            
            quickActionsRegister.register(MMTDetailedMapShortcut(model: MMTUmClimateModel(), map: .Precipitation))
        }
    }
}
