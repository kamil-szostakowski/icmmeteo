//
//  MMTStubs.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 15.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import MeteoModel

@testable import MobileMeteo

class MMTStubLocationService : MMTLocationService
{
    var location: MMTCityProt?
    
    var authorizationStatus: MMTLocationAuthStatus = .unauthorized
    
    func requestLocation() -> MMTPromise<MMTCityProt> {
        return MMTPromise<MMTCityProt>()
    }
}

class MMTUnsupportedShortcut: MMTShortcut
{
    var destination: MMTNavigator.MMTDestination = .meteorogramHere(MMTUmClimateModel())
    
    var identifier: String = ""
}

class StubMigrator : MMTVersionMigrator
{
    private(set) var sequenceNumber: UInt
    private(set) var migrated = false
    
    init(sequenceNumber: UInt)
    {
        self.sequenceNumber = sequenceNumber
        self.migrated = false
    }
    
    func migrate() {
        migrated = true
    }
}

struct StubCitiesStore: MMTCitiesStore
{
    let cities: [MMTCityProt]
    
    init(_ cities: [MMTCityProt]) {
        self.cities = cities
    }
    
    func all(_ completion: ([MMTCityProt]) -> Void) {
        completion(self.cities)
    }
    
    func city(for location: CLLocation, completion: @escaping (MMTResult<MMTCityProt>) -> Void) {}
    
    func cities(matching criteria: String, completion: @escaping ([MMTCityProt]) -> Void) {}
    
    func save(city: MMTCityProt) {}
}
