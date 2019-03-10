//
//  MMTFactory.swift
//  MeteoModel
//
//  Created by szostakowskik on 22.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: Factory protocol
public protocol MMTFactory
{
    var meteorogramCache: MMTMeteorogramCache { get }
    
    var locationService: MMTLocationService { get }
    
    func createTodayModelController(_ :MMTEnvironment) -> MMTTodayModelController
}

// MARK: Default factory implementation
public class MMTDefaultFactory: MMTFactory
{
    // MARK: Properties
    public lazy var meteorogramCache: MMTMeteorogramCache = {
        return MMTSingleMeteorogramStore()
    }()
    
    public lazy var locationService: MMTLocationService = {
        return MMTCoreLocationService(CLLocationManager())
    }()
    
    // MARK: Initializers
    public init() {}
    
    // MARK: Methods
    public func createTodayModelController(_ env: MMTEnvironment) -> MMTTodayModelController
    {
        let forecastService = MMTMeteorogramForecastService(model: MMTUmClimateModel())
        return MMTTodayModelControllerImpl(forecastService, locationService)
    }
}

// MARK: Convinience initializers
public extension MMTRemoteCityGeocoder
{
    public convenience init()
    {
        self.init(general: CLGeocoder())
    }
}

public extension MMTCoreDataCitiesStore
{
    public init()
    {
        self.init(MMTCoreData.instance.context, MMTRemoteCityGeocoder())
    }
}

extension MMTMeteorogramStore
{
    public init(model: MMTClimateModel)
    {
        let cache = MMTCoreData.instance.meteorogramsCache
        let imageStore = MMTWebMeteorogramImageStore(model: model)
        let cachingStore = MMTCachingMeteorogramImageStore(store: imageStore, cache: cache)
        let forecastStore = MMTWebForecastStore(model: model)
        
        self.init(forecastStore, cachingStore)
    }
}

extension MMTWebMeteorogramImageStore
{
    init(model: MMTClimateModel)
    {
        let url = try? URL.mmt_meteorogramDownloadBaseUrl(for: model.type)
        let session = MMTMeteorogramUrlSession(redirectionBaseUrl: url, timeout: 60)
        
        self.init(model: model, session: session)
    }
}

extension MMTWebForecastStore
{
    public init(model: MMTClimateModel)
    {
        let url = try? URL.mmt_meteorogramDownloadBaseUrl(for: model.type)
        let session = MMTMeteorogramUrlSession(redirectionBaseUrl: url, timeout: 60)
        
        self.init(model: model, session: session)
    }
}

extension MMTMeteorogramModelController
{
    public convenience init(city: MMTCityProt, model: MMTClimateModel)
    {
        self.init(city: city, meteorogramStore: MMTMeteorogramStore(model: model), citiesStore: MMTCoreDataCitiesStore())
    }
}

extension MMTDetailedMapPreviewModelController
{
    public convenience init(map: MMTDetailedMap)
    {
        self.init(map: map, dataStore: MMTMeteorogramStore(model: map.climateModel))
    }
}

extension MMTMeteorogramForecastService
{
    public convenience init(model: MMTClimateModel)
    {
        let forecastStore = MMTWebForecastStore(model: model)
        let meteorogramStore = MMTMeteorogramStore(model: model)
        let cache = MMTSingleMeteorogramStore()
        
        self.init(forecastStore: forecastStore, meteorogramStore: meteorogramStore, cache: cache)
    }
}
