//
//  MMTImagesCache.swift
//  MeteoModel
//
//  Created by szostakowskik on 21.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTImagesCache
{
    // MARK: Properties
    private var cache: NSCache<NSString, UIImage>
    
    // MARK
    init(cache: NSCache<NSString, UIImage>)
    {
        self.cache = cache
    }
    
    // MARK: interface methods
    func object(forKey: String) -> UIImage?
    {
        return cache.object(forKey: forKey as NSString)
    }
    
    func setObject(_ object: UIImage, forKey: String)
    {
        cache.setObject(object, forKey: forKey as NSString)
    }
    
    func removeAllObjects()
    {
        cache.removeAllObjects()
    }
}

extension MMTClimateModel
{
    func cacheKey(city: MMTCityProt, startDate: Date) -> String
    {
        return "\(type.rawValue)-\(city.name)-\(startDate)"
    }
    
    func cacheKey(map: MMTDetailedMapType, moment: Date) -> String
    {
        return "\(type.rawValue)-\(map.rawValue)-\(moment)"
    }
    
    func cacheKeyForLegend() -> String
    {
        return "\(type.rawValue)-legend"
    }
}
