//
//  MMTFactory.swift
//  MeteoModel
//
//  Created by szostakowskik on 22.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public extension MMTCityGeocoder
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
        self.init(context: MMTCoreData.instance.context, geocoder: MMTCityGeocoder())
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

extension MMTForecastService
{
    public convenience init(model: MMTClimateModel)
    {
        let forecastStore = MMTWebForecastStore(model: model)
        let meteorogramStore = MMTMeteorogramStore(model: model)
        let citiesStore = MMTCoreDataCitiesStore()
        let cache = MMTCoreData.instance.meteorogramsCache
        
        self.init(forecastStore: forecastStore, meteorogramStore: meteorogramStore, citiesStore: citiesStore, cache: cache)
    }
}
