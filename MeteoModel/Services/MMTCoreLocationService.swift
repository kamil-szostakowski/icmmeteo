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
    private var citiesStore: MMTCitiesStore
    private var promises: [MMTPromise<MMTCityProt>]
    
    public private(set) var authorizationStatus: MMTLocationAuthStatus {
        didSet { NotificationCenter.default.post(name: .locationAuthChangedNotification, object: nil) }
    }
    
    public private(set) var location: MMTCityProt? {
        didSet { NotificationCenter.default.post(name: .locationChangedNotification, object: nil) }
    }
    
    // MARK: Initializers
    public init(_ locationManager: CLLocationManager, _ citiesStore: MMTCitiesStore = MMTCoreDataCitiesStore())
    {
        self.promises = [MMTPromise<MMTCityProt>]()
        self.authorizationStatus = .unauthorized
        self.locationManager = locationManager
        self.citiesStore = citiesStore
        
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }    
}

extension MMTCoreLocationService
{
    // MARK: Interface methods
    public func requestLocation() -> MMTPromise<MMTCityProt>
    {
        let promise = MMTPromise<MMTCityProt>()
        
        if let city = location {
            promise.resolve(with: .success(city))
            return promise
        }
        
        promises.append(promise)
        return promise
    }
}

extension MMTCoreLocationService: CLLocationManagerDelegate
{
    // MARK: Location service methods
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        authorizationStatus = MMTLocationAuthStatus(status)
        
        switch authorizationStatus
        {
            case .unauthorized:
                locationManager.stopMonitoringSignificantLocationChanges()
                updateLocationIfChanged(nil)
                resolvePromises(with: nil)
            default:
                locationManager.startMonitoringSignificantLocationChanges()
        }
        
        setupNotificationHandler(for: authorizationStatus)
        locationManager(locationManager, didUpdateLocations: [])
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        determineCity(for: manager.location) {
            self.updateLocationIfChanged($0)
            self.resolvePromises(with: $0)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        updateLocationIfChanged(nil)
        resolvePromises(with: nil)
    }
    
    @objc public func handleAppActivation(notification: Notification)
    {
        locationManager(locationManager, didUpdateLocations: [])
    }
}

extension MMTCoreLocationService
{
    // MARK: Setup methods
    fileprivate func setupNotificationHandler(for status: MMTLocationAuthStatus)
    {
        guard status != .unauthorized else {
            NotificationCenter.default.removeObserver(self)
            return
        }
        
        let handler = #selector(handleAppActivation(notification:))
        NotificationCenter.default.addObserver(self, selector: handler, name: .UIApplicationDidBecomeActive, object: nil)
    }
}

extension MMTCoreLocationService
{
    // MARK: Data update methods
    fileprivate func determineCity(for location: CLLocation?, completion: @escaping (MMTCityProt?) -> Void)
    {
        guard let aLocation = location else { completion(nil); return }
        determineCity(for: aLocation, completion: completion)
    }
    
    fileprivate func determineCity(for location: CLLocation, completion: @escaping (MMTCityProt?) -> Void)
    {
        citiesStore.city(for: location) {
            switch $0 {
                case let .success(city): completion(city)
                case .failure(_): completion(nil)
            }
        }
    }
    
    fileprivate func resolvePromises(with city: MMTCityProt?)
    {
        let isAuthorized = authorizationStatus != .unauthorized
        let result: MMTResult<MMTCityProt> = city != nil ?
            .success(city!) :
            .failure(isAuthorized ? .locationNotFound : .locationServicesDisabled)
        
        promises.forEach { $0.resolve(with: result) }
        promises.removeAll()
    }
    
    fileprivate func updateLocationIfChanged(_ city: MMTCityProt?)
    {
        if location != city {
            location =  city
        }
    }
}
