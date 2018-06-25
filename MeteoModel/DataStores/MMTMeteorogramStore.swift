//
//  MMTMeteorogramStore.swift
//  MeteoModel
//
//  Created by szostakowskik on 22.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit

public protocol MMTMeteorogramDataStore
{
    var climateModel: MMTClimateModel { get }
    
    func meteorogram(for city: MMTCityProt, completion: @escaping (MMTMeteorogram?, MMTError?) -> Void)
    
    func meteorogram(for map: MMTDetailedMap, completion: @escaping (MMTMapMeteorogram?, MMTError?) -> Void)
}

public struct MMTMeteorogramStore: MMTMeteorogramDataStore
{
    // MARK: Properties
    private let forecastStore: MMTForecastStore
    private let meteorogramImageStore: MMTMeteorogramImageStore
    
    public var climateModel: MMTClimateModel {
        return meteorogramImageStore.climateModel
    }
    
    // MARK: Initializers
    init(_ forecast: MMTForecastStore, _ images: MMTMeteorogramImageStore)
    {
        self.forecastStore = forecast
        self.meteorogramImageStore = images
    }
    
    // MARK: Interface methods
    public func meteorogram(for city: MMTCityProt, completion: @escaping (MMTMeteorogram?, MMTError?) -> Void)
    {
        forecastStore.startDate { (result: MMTResult<Date>) in
            var error: MMTError?            
            var meteorogram: MMTMeteorogram? = MMTMeteorogram(model: self.climateModel)
            
            switch result {
                case let .success(date): meteorogram?.startDate = date
                case .failure(_): meteorogram?.startDate = self.climateModel.startDate(for: Date())
            }
            
            let queue = DispatchQueue.global()
            let group = DispatchGroup()
            
            group.enter()
            queue.async(group: group) {
                self.meteorogramImageStore.getLegend { result in
                    if case let .success(image) = result {
                        meteorogram?.legend = image
                    }
                    group.leave()
                }
            }
            
            group.enter()
            queue.async(group: group) {
                self.meteorogramImageStore.getMeteorogram(for: city, startDate: meteorogram!.startDate) {
                    switch $0 {
                        case let .success(img): meteorogram?.image = img
                        case let .failure(err):
                            error = err
                            meteorogram = nil
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(meteorogram, error)
            }
        }
    }
    
    public func meteorogram(for map: MMTDetailedMap, completion: @escaping (MMTMapMeteorogram?, MMTError?) -> Void)
    {
        forecastStore.startDate {(result: MMTResult<Date>) in
            
            guard case let .success(startDate) = result else {
                completion(nil, .meteorogramFetchFailure)
                return
            }            
            
            let moments = map.forecastMoments(for: startDate)
            var result = [Date : UIImage] ()
            var errorCount = 0
            
            if moments.count == 0 {
                completion(nil, .meteorogramFetchFailure)
            }
            
            var
            meteorogram = MMTMapMeteorogram(model: self.climateModel)
            meteorogram.startDate = startDate
            meteorogram.moments = moments

            let queue = DispatchQueue.global()
            let group = DispatchGroup()
            
            for date in moments
            {
                group.enter()
                queue.async(group: group) {
                    self.meteorogramImageStore.getMeteorogram(for: map, moment: date, startDate: startDate) {
                        
                        switch $0 {
                            case let .success(img): result[date] = img
                            case .failure(_): errorCount += 1
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                guard errorCount < moments.count/2 else {
                    completion(nil, .meteorogramFetchFailure)
                    return
                }
                
                meteorogram.images = moments.map { result[$0] }
                completion(meteorogram, nil)
            }
        }
    }
}
