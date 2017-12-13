//
//  MMTLocationService.swift
//  MobileMeteo
//
//  Created by szostakowskik on 11.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

class MMTLocationService : NSObject, MMTService
{
    // MARK: Properties
    private let locationManager: CLLocationManager
    
    @objc dynamic private(set) var currentLocation: CLLocation?
    
    // MARK: Initializers
    init(manager: CLLocationManager)
    {
        locationManager = manager
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: Interface methods
    func start()
    {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func stop()
    {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func update()
    {
        currentLocation = locationManager.location
    }
}

extension MMTLocationService: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedWhenInUse {
            locationManager.startMonitoringSignificantLocationChanges()
            currentLocation = locationManager.location
            
        } else {
            locationManager.stopMonitoringSignificantLocationChanges()
            currentLocation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        update()
    }
}

