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
        let climateModel = meteorogramImageStore.climateModel
        
        var data: (met: UIImage?, leg: UIImage?, date: Date?, err: MMTError?)
        
        queue.async(group: group) {
            group.enter()
            self.forecastStore.startDate { (date: Date?, error: MMTError?) in
                data.date = date ?? climateModel.startDate(for: Date())
                group.leave()
            }
        }
        
        queue.async(group: group) {
            
            let key = "\(climateModel.type.rawValue)-legend" as NSString
            
            if let cachedImage = self.cache.object(forKey: key) {
                data.leg = cachedImage
                return
            }
            
            group.enter()
            self.meteorogramImageStore.getLegend { (image: UIImage?, error: MMTError?) in
                data.leg = image
                
                if error == nil {
                    self.cache.setObject(image!, forKey: key)
                }
                
                group.leave()
            }
        }
        
        queue.async(group: group) {
            
            let forecastStartDate = climateModel.startDate(for: Date())
            let key = "\(climateModel.type.rawValue)-\(city.name)-\(forecastStartDate)" as NSString
            
            if let cachedImage = self.cache.object(forKey: key) {
                data.met = cachedImage
                return
            }

            group.enter()
            self.meteorogramImageStore.getMeteorogram(for: city) { (image: UIImage?, error: MMTError?) in
                data.met = image
                data.err = error
                
                if error == nil {
                    self.cache.setObject(image!, forKey: key)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: queue) {
            guard let meteorogram = MMTMeteorogram(model: climateModel, data: data) else {
                DispatchQueue.main.async { completion(nil, .meteorogramFetchFailure) }
                return
            }
            DispatchQueue.main.async { completion(meteorogram, nil) }
        }
    }
}

extension MMTMeteorogram
{
    init?(model: MMTClimateModel, data: (met: UIImage?, leg: UIImage?, date: Date?, err: MMTError?))
    {
        guard let date = data.date, let meteorogram = data.met else {
            return nil
        }
        
        self.image = meteorogram
        self.legend = data.leg
        self.startDate = date
        self.model = model
    }
}
