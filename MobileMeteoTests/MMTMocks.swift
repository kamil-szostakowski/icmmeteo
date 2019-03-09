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

// MARK: Mock factory
class MMTMockFactory: MMTFactory
{
    // MARK: Configuration Properties
    var forecastUpdateResult: MMTUpdateResult!
    var cachedMeteorogram: MMTMeteorogram?

    // MARK: Interface methods
    lazy var locationService: MMTLocationService = {
        return MMTMockLocationService()
    }()
    
    lazy var meteorogramCache: MMTMeteorogramCache = {
        let
        cache = MMTMockMeteorogramCache()
        cache.meteorogram = cachedMeteorogram
        return cache
    }()

    func createTodayModelController(_: MMTEnvironment) -> MMTTodayModelController {
        let
        modelController = MMTMockTodayModelController()
        modelController.result = forecastUpdateResult
        return modelController
    }
}

// MAKR: Mocks
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

class MMTMockMeteorogramCache: MMTMeteorogramCache
{
    var meteorogram: MMTMeteorogram?
    
    @discardableResult
    func store(_ meteorogram: MMTMeteorogram) -> Bool {
        self.meteorogram = meteorogram
        return true
    }
    
    func restore() -> MMTMeteorogram? {
        return meteorogram
    }
    
    @discardableResult
    func cleanup() -> Bool {
        self.meteorogram = nil
        return true
    }
}

class MMTMockLocationService: MMTLocationService
{
    var location: MMTCityProt?
    var authorizationStatus: MMTLocationAuthStatus = .unauthorized
    var locationPromise = MMTPromise<MMTCityProt>()
    
    func requestLocation() -> MMTPromise<MMTCityProt> {
        return locationPromise
    }
}

class MMTMockTodayModelController: MMTTodayModelController
{
    // MARK: Properties
    weak var delegate: MMTModelControllerDelegate?
    var updateResult: MMTResult<MMTMeteorogram> = .failure(.forecastUndetermined)
    var result: MMTUpdateResult = .noData
    
    // MARK: Methods
    func activate() {}
    
    func deactivate() {}
    
    func onUpdate(completion: @escaping (MMTUpdateResult) -> Void) {
        completion(result)
    }
    
    func onUpdate(_ city: MMTCityProt, completion: @escaping (MMTUpdateResult) -> Void) {
        completion(result)
    }
}
