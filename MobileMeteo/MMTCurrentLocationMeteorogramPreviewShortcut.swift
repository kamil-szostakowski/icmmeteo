//
//  MMTCurrentLocationMeteorogramPreviewShortcut.swift
//  MobileMeteo
//
//  Created by szostakowskik on 22.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import CoreLocation

class MMTCurrentLocationMeteorogramPreviewShortcut: MMTMeteorogramPreviewShortcut
{
    private var retryCount: Int = 0
    private let RETRY_MAX_COUNT = 5
    
    override var identifier: String {
        return "current-location"
    }
    
    convenience init(model: MMTClimateModel)
    {
        let name = MMTLocalizedString("forecast.here")
        let location = MMTServiceProvider.locationService.currentLocation ?? .zero
        let city = MMTCity(name: name, region: "", location: location)
        
        self.init(model: model, city: city)
    }
    
    override init(model: MMTClimateModel, city: MMTCityProt)
    {
        super.init(model: model, city: city)
    }
    
    override func execute(using tabbar: MMTTabBarController, completion: MMTCompletion?)
    {
        guard retryCount < RETRY_MAX_COUNT else {
            completion?()
            return
        }
        
        guard MMTServiceProvider.locationService.currentLocation != nil, location != .zero else {
            retry(after: 1, using: tabbar, completion: completion)
            return
        }
        
        super.execute(using: tabbar, completion: completion)
    }
    
    private func retry(after seconds: UInt64, using tabbar: MMTTabBarController, completion: MMTCompletion?)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: seconds * 1000)) {
            self.retryCount += 1
            self.location = MMTServiceProvider.locationService.currentLocation ?? .zero
            self.execute(using: tabbar, completion: completion)
        }
    }
}

fileprivate extension CLLocation
{
    static var zero: CLLocation {
        return CLLocation(latitude: 0, longitude: 0)
    }
}
