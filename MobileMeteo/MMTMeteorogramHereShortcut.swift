//
//  MMTCurrentLocationMeteorogramPreviewShortcut.swift
//  MobileMeteo
//
//  Created by szostakowskik on 22.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import CoreLocation
import MeteoModel

class MMTMeteorogramHereShortcut: MMTMeteorogramShortcut
{
    private var retryCount: Int = 0
    private let RETRY_MAX_COUNT = 5
    private let locationService: MMTLocationService
    
    override var identifier: String {
        return "current-location"
    }
    
    init(model: MMTClimateModel, locationService service: MMTLocationService)
    {
        let name = MMTLocalizedString("forecast.here")
        let location = service.currentLocation ?? .zero        
        let city = MMTCityProt(name: name, region: "", location: location)
        
        locationService = service
        super.init(model: model, city: city)
    }
    
    override func execute(using tabbar: MMTTabBarController, completion: (() -> Void)?)
    {
        tabbar.displayActivityIndicator(in: tabbar.view, message: nil)
        
        guard retryCount < RETRY_MAX_COUNT else {
            tabbar.hideActivityIndicator()
            tabbar.present(UIAlertController.alertForMMTError(.locationNotFound), animated: true, completion: nil)
            completion?()
            return
        }
        
        guard locationService.currentLocation != nil, location != .zero else {
            retry(after: 1, using: tabbar, completion: completion)
            return
        }
        
        super.execute(using: tabbar) {
            tabbar.hideActivityIndicator()
            completion?()
        }
    }
    
    private func retry(after seconds: UInt64, using tabbar: MMTTabBarController, completion: (() -> Void)?)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: seconds * 1000)) {
            self.retryCount += 1
            self.location = self.locationService.currentLocation ?? .zero
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
