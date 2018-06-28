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

public enum MMTUpdateResult
{
    case newData
    case noData
    case failed
}

public class MMTForecastService
{
    // MARK: Properties
    fileprivate var forecastStore: MMTForecastStore
    fileprivate var meteorogramStore: MMTMeteorogramDataStore
    fileprivate var citiesStore: MMTCitiesStore
    fileprivate var cache: MMTImagesCache
    
    public private(set) var currentMeteorogram: MMTMeteorogram?
    
    // MARK: Initializers
    public init(forecastStore: MMTForecastStore, meteorogramStore: MMTMeteorogramDataStore, citiesStore: MMTCitiesStore, cache: MMTImagesCache)
    {
        self.forecastStore = forecastStore
        self.meteorogramStore = meteorogramStore
        self.citiesStore = citiesStore
        self.cache = cache
    }
    
    // MARK: Interface methods
    public func update(for location: CLLocation?, completion: @escaping (MMTUpdateResult) -> Void)
    {
        guard let aLocation = location else {
            completion(.noData)
            return
        }
        
        let queue = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        
        var aCity: MMTCityProt?
        var aStartDate: Date?

        group.enter()
        queue.async(group: group) {
            self.forecastStore.startDate { (result: MMTResult<Date>) in                                
                if case let .success(date) = result {
                    aStartDate = date
                }
                group.leave()
            }
        }
        
        group.enter()
        queue.async(group: group) {
            self.citiesStore.city(for: aLocation) {
                if case let .success(city) = $0 {
                    aCity = city
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            guard let city = aCity, let startDate = aStartDate else {
                completion(.failed)
                return
            }
            
            guard self.isUpdateRequired(city, startDate) == true else {
                completion(.noData)
                return
            }
            
            self.meteorogramStore.meteorogram(for: city) {
                
                if case let .success(meteorogram) = $0
                {
                    self.currentMeteorogram = meteorogram                    
                    self.pinToCache(meteorogram: meteorogram)
                    completion(.newData)
                }
                
                if case .failure(_) = $0 {
                    completion(.failed)
                }                                
            }
        }
    }
}

extension MMTForecastService
{
    // MARK: Helper methods
    fileprivate func isUpdateRequired(_ city: MMTCityProt, _ startDate: Date) -> Bool
    {
        let old: (MMTCityProt?, Date?) = (currentMeteorogram?.city, currentMeteorogram?.startDate)
        let new: (MMTCityProt?, Date?) = (city, startDate)
        
        return old != new
    }
    
    fileprivate func pinToCache(meteorogram m: MMTMeteorogram)
    {
        let key = m.model.cacheKey(city: m.city, startDate: m.startDate)
        cache.setPinnedObject(m.image, forKey: key)
    }
}
