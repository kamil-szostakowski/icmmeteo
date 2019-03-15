//
//  MMTCache.swift
//  MeteoModel
//
//  Created by szostakowskik on 14/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTCacheManager
{
    // MARK: Properties
    private var meteorogramCache: MMTMeteorogramCache
    private var imagesCache: MMTImagesCache
    
    // MARK: initializers
    init(_ meteorogramCache: MMTMeteorogramCache, _ imagesCache: MMTImagesCache)
    {
        self.meteorogramCache = meteorogramCache
        self.imagesCache = imagesCache
    }
    
    // MARK: Interface methods
    
    @discardableResult
    func sync() -> Bool
    {
        guard let mgram = meteorogramCache.restore() else {
            return false
        }
        
        let key = mgram.model.cacheKey(city: mgram.city, startDate: mgram.startDate)
        imagesCache.setObject(mgram.image, forKey: key)
        
        return true
    }
    
    func cleanup()
    {
        meteorogramCache.cleanup()
        imagesCache.removeAllObjects()
    }
}
