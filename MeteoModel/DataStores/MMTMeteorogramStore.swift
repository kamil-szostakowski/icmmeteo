//
//  MMTMeteorogramStore.swift
//  MeteoModel
//
//  Created by szostakowskik on 22.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit

public typealias MMTImagesCache = NSCache<NSString, UIImage>

public struct MMTMeteorogramStore
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
        forecastStore.startDate { (date: Date?, error: MMTError?) in
            var error: MMTError?
            
            var
            meteorogram: MMTMeteorogram? = MMTMeteorogram(model: self.climateModel)
            meteorogram?.startDate = date ?? self.climateModel.startDate(for: Date())
            
            let queue = DispatchQueue.global()
            let group = DispatchGroup()
            
            group.enter()
            queue.async(group: group) {
                self.meteorogramImageStore.getLegend { (image: UIImage?, error: MMTError?) in
                    meteorogram?.legend = image
                    group.leave()
                }
            }
            
            group.enter()
            queue.async(group: group) {
                self.meteorogramImageStore.getMeteorogram(for: city, startDate: meteorogram!.startDate) {
                    (image: UIImage?, err: MMTError?) in
                    
                    error = err
                    
                    if let img = image {
                        meteorogram?.image = img
                    }
                    
                    if err != nil {
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
        forecastStore.startDate {(date: Date?, error: MMTError?) in
            guard let startDate = date else {
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
                        (image: UIImage?, error: MMTError?) in
                        
                        if error != nil {
                            errorCount += 1                            
                        } else if let img = image {
                            result[date] = img
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
