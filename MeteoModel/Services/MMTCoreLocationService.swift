//
//  MMTCoreLocationService.swift
//  MeteoModel
//
//  Created by szostakowskik on 08.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTCoreLocationService: NSObject, MMTLocationService, MMTAnalyticsReporter
{
    public var analytics: MMTAnalytics?
    
    // MARK: Properties
    private var locationManager: CLLocationManager
    
    public private(set) var authorizationStatus: MMTLocationAuthStatus
    
    public var currentLocation: CLLocation? {
        return locationManager.location
    }
    
    // MARK: Initializers
    public init(locationManager: CLLocationManager)
    {
        self.authorizationStatus = .unauthorized
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
        authorizationStatus = MMTLocationAuthStatus(status)
        
        switch authorizationStatus {
            case .unauthorized:
                locationManager.stopMonitoringSignificantLocationChanges()
            default:
                locationManager.startMonitoringSignificantLocationChanges()
        }
        
        setupNotificationHandler(for: authorizationStatus)
        locationManager(manager, didUpdateLocations: [])
        analytics?.sendUserActionReport(.Locations, action: MMTAnalyticsAction(status), actionLabel: "")
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

extension MMTCoreLocationService
{
    fileprivate func setupNotificationHandler(for status: MMTLocationAuthStatus)
    {
        guard status != .unauthorized else {
            NotificationCenter.default.removeObserver(self)
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppActivation(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
}

extension MMTLocationAuthStatus
{
    // MAKR: Converter extension
    fileprivate init(_ status: CLAuthorizationStatus)
    {
        switch status {
            case .authorizedWhenInUse: self = .whenInUse
            case .authorizedAlways: self = .always
            default: self = .unauthorized
        }
    }
}

extension MMTAnalyticsAction
{
    // MAKR: Converter extension
    fileprivate init(_ status: CLAuthorizationStatus)
    {
        switch status {
            case .authorizedWhenInUse: self = .LocationDidAllowWhenUsing
            case .authorizedAlways: self = .LocationDidAllowAlways
            default: self = .LocationDidAllowNever
        }
    }
}
