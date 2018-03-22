//
//  MMTUmMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

public typealias MMTImagesCache = NSCache<NSString, UIImage>

public struct MMTMeteorogramImageStore
{
    // MARK: Properties
    private var cache: MMTImagesCache
    private let urlSession: MMTMeteorogramUrlSession
    private let forecastStartDate: Date
    public let climateModel: MMTClimateModel
    
    // MARK: Initializers
    public init(model: MMTClimateModel, date: Date, session: MMTMeteorogramUrlSession, cache: MMTImagesCache)
    {
        self.cache = cache
        self.urlSession = session
        self.climateModel = model
        self.forecastStartDate = date
    }
    
    public init(model: MMTClimateModel, date: Date, cache: MMTImagesCache)
    {
        let url = try? URL.mmt_meteorogramDownloadBaseUrl(for: model.type)
        let session = MMTMeteorogramUrlSession(redirectionBaseUrl: url, timeout: 60)
        
        self.init(model: model, date: date, session: session, cache: cache)
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
