//
//  MMTFactory.swift
//  MeteoModel
//
//  Created by szostakowskik on 22.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

// MARK: Factory protocol
public protocol MMTFactory
{
    var locationService: MMTLocationService { get }
    
    func createTodayModelController(_ :MMTEnvironment) -> MMTTodayModelController
}

// MARK: Default factory implementation
public class MMTDefaultFactory: MMTFactory
{
    // MARK: Public properties
    public static let shared = MMTDefaultFactory()
    
    public lazy var locationService: MMTLocationService = {
        return MMTCoreLocationService(CLLocationManager())
    }()
    
    // MARK: Private properties
    fileprivate lazy var imagesCache: MMTImagesCache = {
        return MMTImagesCache(cache: NSCache<NSString, UIImage>())
    }()
    
    fileprivate lazy var meteorogramCache: MMTMeteorogramCache = {
        return MMTSingleMeteorogramStore()
    }()
    
    fileprivate var cacheManager: MMTCacheManager {
        return MMTCacheManager(meteorogramCache, imagesCache)
    }
    
    // MARK: Initializers
    public init() {}
    
    // MARK: Methods
    public func createTodayModelController(_ env: MMTEnvironment) -> MMTTodayModelController
    {
        let mlModel = env == .normal ? MMTCoreMLPredictionModel() : nil
        let forecastService = createForecastService(mlModel)
        let locationServ = createLocationService(env)
        
        return MMTTodayModelControllerImpl(forecastService, locationServ)
    }
}

// MARK: Helper extension
extension MMTDefaultFactory
{
    fileprivate func createForecastService(_ mlModel: MMTPredictionModel?) -> MMTForecastService
    {
        let model = MMTUmClimateModel()
        let forecastStore = MMTWebForecastStore(model: model)
        let meteorogramStore = MMTMeteorogramStore(model: model)
        
        return MMTMeteorogramForecastService(forecastStore, meteorogramStore, meteorogramCache, mlModel)
    }
    
    fileprivate func createLocationService(_ env: MMTEnvironment) -> MMTLocationService
    {
        return env == .normal ? locationService : MMTCachedLocationService(meteorogramCache)
    }
}

public class MeteoModel
{
    public static func syncCaches()
    {
        DispatchQueue.global(qos: .background).async {
            MMTDefaultFactory.shared.cacheManager.sync()
        }
    }
    
    public static func cleanupCaches()
    {
        DispatchQueue.global(qos: .background).async {
            MMTDefaultFactory.shared.cacheManager.cleanup()
        }
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
        let cache = MMTDefaultFactory.shared.imagesCache
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
