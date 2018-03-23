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
    private let cache: MMTImagesCache
    
    public var climateModel: MMTClimateModel {
        return meteorogramImageStore.climateModel
    }
    
    // MARK: Initializers
    init(_ forecast: MMTForecastStore, _ images: MMTMeteorogramImageStore, _ cache: MMTImagesCache)
    {
        self.forecastStore = forecast
        self.meteorogramImageStore = images
        self.cache = cache
    }
    
    // MARK: Interface methods
    public func meteorogram(for city: MMTCityProt, completion: @escaping (MMTMeteorogram?, MMTError?) -> Void)
    {
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        
        var meteorogram: MMTMeteorogram? = MMTMeteorogram(model: self.climateModel)
        var error: MMTError?
        
        queue.async(group: group) {
            group.enter()
            self.forecastStore.startDate { (date: Date?, error: MMTError?) in
                meteorogram?.startDate = date ?? self.climateModel.startDate(for: Date())
                group.leave()
            }
        }
        
        queue.async(group: group) {
            
            let key = "\(self.climateModel.type.rawValue)-legend" as NSString
            
            if let cachedImage = self.cache.object(forKey: key) {
                meteorogram?.legend = cachedImage
                return
            }
            
            group.enter()
            self.meteorogramImageStore.getLegend { (image: UIImage?, error: MMTError?) in
                meteorogram?.legend = image
                
                if error == nil {
                    self.cache.setObject(image!, forKey: key)
                }
                
                group.leave()
            }
        }
        
        queue.async(group: group) {
            
            let forecastStartDate = self.climateModel.startDate(for: Date())
            let key = "\(self.climateModel.type.rawValue)-\(city.name)-\(forecastStartDate)" as NSString
            
            if let cachedImage = self.cache.object(forKey: key) {
                meteorogram?.image = cachedImage
                return
            }

            group.enter()
            self.meteorogramImageStore.getMeteorogram(for: city) { (image: UIImage?, err: MMTError?) in
                
                if err != nil
                {
                    error = err
                    meteorogram = nil
                }
                else if let img = image
                {
                    meteorogram?.image = img
                    self.cache.setObject(img, forKey: key)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: queue) {
            DispatchQueue.main.async { completion(meteorogram, error) }
        }
    }
    
    public func meteorogram(for map: MMTDetailedMap, completion: @escaping (MMTMapMeteorogram?, MMTError?) -> Void)
    {
        forecastStore.startDate {(date: Date?, error: MMTError?) in
            guard let startDate = date else {
                completion(nil, .meteorogramFetchFailure)
                return
            }
                                    
            // TODO: Handle scenario when there are no moments
            let moments = map.forecastMoments(for: self.climateModel, forecastStart: startDate)
            var result = [Date : UIImage] ()
            var errorCount = 0
            
            var
            meteorogram = MMTMapMeteorogram(model: self.climateModel)
            meteorogram.startDate = startDate
            meteorogram.moments = moments
            
            let queue = DispatchQueue.global()
            let group = DispatchGroup()
            
            for date in moments
            {
                let key = "\(self.climateModel.type.rawValue)-\(map.type.rawValue)-\(date)" as NSString
                
                if let img = self.cache.object(forKey: key) {
                    result[date] = img
                    continue
                }
                
                queue.async(group: group) {
                    group.enter()
                    
                    self.meteorogramImageStore.getMeteorogram(for: map, moment: date, startDate: startDate) {
                        (image: UIImage?, error: MMTError?) in
                        
                        if error != nil {
                            errorCount += 1
                        } else if let img = image {
                            self.cache.setObject(img, forKey: key)
                            result[date] = img
                        }
                        
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: queue) {
                guard errorCount < moments.count/2 else {
                    DispatchQueue.main.async { completion(nil, .meteorogramFetchFailure) }
                    return
                }
                
                meteorogram.images = moments.map { result[$0] }
                DispatchQueue.main.async { completion(meteorogram, nil) }
            }
        }
    }
}
