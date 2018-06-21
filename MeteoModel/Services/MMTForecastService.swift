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

public class MMTForecastService
{
    // MARK: Properties
    fileprivate var forecastStore: MMTForecastStore
    fileprivate var meteorogramStore: MMTMeteorogramDataStore
    fileprivate var citiesStore: MMTCitiesStore
    
    fileprivate var currentCity: MMTCityProt?
    fileprivate var currentStartDate: Date?
    
    // MARK: Initializers
    public init(forecastStore: MMTForecastStore, meteorogramStore: MMTMeteorogramDataStore, citiesStore: MMTCitiesStore)
    {
        self.forecastStore = forecastStore
        self.meteorogramStore = meteorogramStore
        self.citiesStore = citiesStore
    }
    
    // MARK: Interface methods
    public func update(for location: CLLocation?, completion: @escaping (UIBackgroundFetchResult) -> Void)
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
            self.forecastStore.startDate { date, error in
                aStartDate = date
                group.leave()
            }
        }
        
        group.enter()
        queue.async(group: group) {
            self.citiesStore.city(for: aLocation) { city, error in
                aCity = city
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
            
            self.currentCity = city
            self.currentStartDate = startDate
            self.meteorogramStore.meteorogram(for: city) { meteorogram, error in             
                completion(error != nil ? .newData : .failed)
            }
        }
    }
}

extension MMTForecastService
{
    // MARK: Helper methods
    fileprivate func isUpdateRequired(_ city: MMTCityProt, _ startDate: Date) -> Bool
    {
        let old: (MMTCityProt?, Date?) = (currentCity, currentStartDate)
        let new: (MMTCityProt?, Date?) = (city, startDate)
        
        return old != new
    }
}
