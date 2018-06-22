//
//  MMTCachingMeteorogramImageStore.swift
//  MeteoModel
//
//  Created by szostakowskik on 26.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit

struct MMTCachingMeteorogramImageStore : MMTMeteorogramImageStore
{
    // MARK: Properties
    let imageCache: MMTImagesCache
    let climateModel: MMTClimateModel
    let imageStore: MMTMeteorogramImageStore
    
    // MARK: Initializer
    init(store: MMTMeteorogramImageStore, cache: MMTImagesCache)
    {
        imageCache = cache
        imageStore = store
        climateModel = store.climateModel
    }
    
    // MARK: Interface methods
    func getMeteorogram(for city: MMTCityProt, startDate: Date, completion: @escaping (UIImage?, MMTError?) -> Void)
    {
        let key = climateModel.cacheKey(city: city, startDate: startDate)
        
        if let cachedImage = imageCache.object(forKey: key) {
            completion(cachedImage, nil)
            return
        }

        imageStore.getMeteorogram(for: city, startDate: startDate) { (image, error) in
            if let img = image {
                self.imageCache.setObject(img, forKey: key)
            }
            completion(image, error)
        }
    }
    
    func getLegend(_ completion: @escaping (UIImage?, MMTError?) -> Void)
    {
        let key = climateModel.cacheKeyForLegend()
        
        if let cachedImage = imageCache.object(forKey: key) {
            completion(cachedImage, nil)
            return
        }

        imageStore.getLegend { (image, error) in
            if let img = image {
                self.imageCache.setObject(img, forKey: key)
            }
            completion(image, error)
        }
    }
    
    func getMeteorogram(for map: MMTDetailedMap, moment: Date, startDate: Date, completion: @escaping (UIImage?, MMTError?) -> Void)
    {
        let key = climateModel.cacheKey(map: map.type, moment: moment)
        
        if let img = imageCache.object(forKey: key) {
            completion(img, nil)
            return
        }

        imageStore.getMeteorogram(for: map, moment: moment, startDate: startDate) { (image, error) in
            if let img = image {
                self.imageCache.setObject(img, forKey: key)
            }
            completion(image, error)
        }
    }

}
