//
//  MMTUmMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTMeteorogramStore: MMTForecastStore
{
    // MARK: Properties
    fileprivate var cache: NSCache<NSString, UIImage> {
        return MMTDatabase.instance.meteorogramsCache
    }
    
    // MARK: Methods
    public func getMeteorogram(for city: MMTCityProt, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let url = try! URL.mmt_meteorogramSearchUrl(for: climateModel.type, location: city.location)
        let cacheKey = "\(climateModel.type.rawValue)-\(city.name)-\(forecastStartDate)" as NSString
        
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage, nil)
            return
        }
        
        urlSession.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) in
            
            if error == nil {
                self.cache.setObject(image!, forKey: cacheKey)
            }
            
            completion(image, error)
        }
    }
    
    public func getLegend(_ completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let url = try! URL.mmt_meteorogramLegendUrl(for: climateModel.type)
        let cacheKey = "\(climateModel.type.rawValue)-legend" as NSString
        
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage, nil)
            return
        }
        
        urlSession.fetchImageFromUrl(url) {
            (image: UIImage?, error: MMTError?) in
            
            if error == nil {
                self.cache.setObject(image!, forKey: cacheKey)
            }
            
            completion(image, error)
        }
    }
}
