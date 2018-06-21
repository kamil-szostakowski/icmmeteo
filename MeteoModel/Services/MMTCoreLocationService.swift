//
//  MMTCoreLocationService.swift
//  MeteoModel
//
//  Created by szostakowskik on 08.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTCoreLocationService: NSObject, MMTLocationService
{
    // MARK: Properties
    private var locationManager: CLLocationManager
    
    public var currentLocation: CLLocation? {
        return locationManager.location
    }
    
    // MARK: Initializers
    public init(locationManager: CLLocationManager)
    {
        self.locationManager = locationManager
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
}

extension MMTCoreLocationService: CLLocationManagerDelegate
{
    // MARK: Location service methods
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedWhenInUse {
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager(manager, didUpdateLocations: [])
            NotificationCenter.default.addObserver(self, selector: #selector(handleAppActivation(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
        } else {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager(manager, didUpdateLocations: [])
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc public func handleAppActivation(notification: Notification)
    {
        NotificationCenter.default.post(name: .locationChangedNotification, object: nil)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        NotificationCenter.default.post(name: .locationChangedNotification, object: nil)
    }
}

