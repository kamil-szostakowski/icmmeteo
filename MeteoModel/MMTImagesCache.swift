//
//  MMTImagesCache.swift
//  MeteoModel
//
//  Created by szostakowskik on 21.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

public class MMTImagesCache
{
    // MARK: Properties
    private var cache: NSCache<NSString, UIImage>
    private var pinnedCache: Dictionary<String, UIImage>
    
    // MARK
    init(cache: NSCache<NSString, UIImage>)
    {
        self.cache = cache
        self.pinnedCache = Dictionary<String, UIImage>()
    }
    
    // MARK: interface methods
    func object(forKey: String) -> UIImage?
    {
        if let discardableObject = cache.object(forKey: forKey as NSString) {
            return discardableObject
        }
        
        return pinnedCache[forKey]
    }
    
    func setObject(_ object: UIImage, forKey: String)
    {
        cache.setObject(object, forKey: forKey as NSString)
    }
    
    func setPinnedObject(_ object: UIImage, forKey: String)
    {
        setObject(object, forKey: forKey)        
        pinnedCache.removeAll()
        pinnedCache[forKey] = object
    }
    
    func removeAllObjects()
    {
        cache.removeAllObjects()
        pinnedCache.removeAll()
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
