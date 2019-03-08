//
//  MMTForecastService.swift
//  MeteoModel
//
//  Created by szostakowskik on 20.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

public class MMTMeteorogramForecastService: MMTForecastService
{    
    // MARK: Properties
    fileprivate var forecastStore: MMTForecastStore
    fileprivate var meteorogramStore: MMTMeteorogramDataStore
    fileprivate var cache: MMTMeteorogramCache
    
    public private(set) var currentMeteorogram: MMTMeteorogram?
    
    // MARK: Initializers    
    public init(forecastStore: MMTForecastStore, meteorogramStore: MMTMeteorogramDataStore, cache: MMTMeteorogramCache)
    {
        self.forecastStore = forecastStore
        self.meteorogramStore = meteorogramStore
        self.cache = cache
    }
    
    // MARK: Interface methods
    public func update(for location: MMTCityProt, completion: @escaping (MMTUpdateResult) -> Void)
    {
        let ui = DispatchQueue.main
        let queue = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        var aStartDate: Date?
        
        group.enter()
        queue.async(group: group) {
            self.currentMeteorogram = self.cache.restore()
            group.leave()
        }

        group.enter()
        forecastStore.startDate { (result: MMTResult<Date>) in
            if case let .success(date) = result {
                aStartDate = date
            }
            group.leave()
        }
        
        group.notify(queue: queue) {
            guard let startDate = aStartDate else {
                ui.async { completion(.failed) }
                return
            }
            
            guard self.isUpdateRequired(location, startDate) == true else {
                ui.async { completion(.noData) }
                return
            }
            
            self.meteorogramStore.meteorogram(for: location) {
                
                if case let .success(meteorogram) = $0 {
                    self.currentMeteorogram = meteorogram
                    self.cache.store(meteorogram)                    
                    ui.async { completion(.newData) }
                }
                
                if case .failure(_) = $0 {
                    ui.async { completion(.failed) }
                }                                
            }
        }
    }
}

extension MMTMeteorogramForecastService
{
    // MARK: Helper methods
    fileprivate func isUpdateRequired(_ city: MMTCityProt, _ startDate: Date) -> Bool
    {
        let old: (MMTCityProt?, Date?) = (currentMeteorogram?.city, currentMeteorogram?.startDate)
        let new: (MMTCityProt?, Date?) = (city, startDate)
        
        return old != new
    }
    
//    fileprivate func pinToCache(meteorogram m: MMTMeteorogram)
//    {
//        let key = m.model.cacheKey(city: m.city, startDate: m.startDate)
//        cache.setPinnedObject(m.image, forKey: key)
//    }
}
