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
        let meteorogramImageStore = MMTWebMeteorogramImageStore(model: model)
        let forecastStore = MMTWebForecastStore(model: model)
        
        self.init(forecastStore, meteorogramImageStore, cache)
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
