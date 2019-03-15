//
//  MMTCachedLocationService.swift
//  MeteoModel
//
//  Created by szostakowskik on 15/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTCachedLocationService: MMTLocationService
{
    // MARK: Properties
    private(set) var location: MMTCityProt?
    private(set) var authorizationStatus: MMTLocationAuthStatus = .whenInUse
    private var cache: MMTMeteorogramCache
    
    // MARK: Initializers
    init(_ cache: MMTMeteorogramCache)
    {
        self.cache = cache
    }
    
    // MARK: Interface methods
    func requestLocation() -> MMTPromise<MMTCityProt>
    {
        let promise = MMTPromise<MMTCityProt>()
        
        DispatchQueue.global(qos: .background).async {
            guard let meteorogram = self.cache.restore() else {
                self.location = nil
                promise.resolve(with: .failure(.locationNotFound))
                return
            }
            self.location = meteorogram.city
            promise.resolve(with: .success(meteorogram.city))
        }
        
        return promise
    }
}
