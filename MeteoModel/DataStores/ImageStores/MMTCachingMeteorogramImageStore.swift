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
    func getMeteorogram(for city: MMTCityProt, startDate: Date, completion: @escaping (MMTResult<UIImage>) -> Void)
    {
        let key = climateModel.cacheKey(city: city, startDate: startDate)
        
        if let cachedImage = imageCache.object(forKey: key) {
            print("METEOROGRAM GOT FROM CACHE")
            completion(.success(cachedImage))
            return
        }

        imageStore.getMeteorogram(for: city, startDate: startDate) {
            if case let .success(img) = $0 {
                print("METEOROGRAM SAVED TO CACHE")
                self.imageCache.setObject(img, forKey: key)
            }
            completion($0)
        }
    }
    
    func getLegend(_ completion: @escaping (MMTResult<UIImage>) -> Void)
    {
        let key = climateModel.cacheKeyForLegend()
        
        if let cachedImage = imageCache.object(forKey: key) {
            completion(.success(cachedImage))
            return
        }

        imageStore.getLegend { result in
            if case let .success(img) = result {
                self.imageCache.setObject(img, forKey: key)
            }
            completion(result)
        }
    }
    
    func getMeteorogram(for map: MMTDetailedMap, moment: Date, startDate: Date, completion: @escaping (MMTResult<UIImage>) -> Void)
    {
        let key = climateModel.cacheKey(map: map.type, moment: moment)
        
        if let img = imageCache.object(forKey: key) {
            completion(.success(img))
            return
        }

        imageStore.getMeteorogram(for: map, moment: moment, startDate: startDate) { result in
            if case let .success(img) = result {
                self.imageCache.setObject(img, forKey: key)
            }
            completion(result)
        }
    }

}
