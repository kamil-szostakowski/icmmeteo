//
//  MMTCoreLocationServiceTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 28.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import CoreLocation
@testable import MeteoModel

class MMTCoreLocationServiceTests: XCTestCase
{
    // MARK: Properties
    var service: MMTCoreLocationService!
    var locationManager: MMTMockLocationManager!
    var citiesStore: MMTMockCitiesStore!
    
    var loremCity = MMTCityProt(name: "Lorem", region: "Loremia")
    var ipsumCity = MMTCityProt(name: "Ipsum", region: "Ipsumia")
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        locationManager = MMTMockLocationManager()
        citiesStore = MMTMockCitiesStore()
        
        service = MMTCoreLocationService(locationManager, citiesStore)
        locationManager.delegate = nil
    }
    
    override func tearDown()
    {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        NotificationCenter.default.removeObserver(service)
        super.tearDown()
    }
    
    // MARK: Test methods
    func testInitialization()
    {
        XCTAssertEqual(service.authorizationStatus, .unauthorized)
    }
    
    func testAuthorization()
    {
        verifyAuthorization(.authorizedAlways, .always)
        verifyAuthorization(.authorizedWhenInUse, .whenInUse)
        verifyAuthorization(.notDetermined, .unauthorized)
        verifyAuthorization(.denied, .unauthorized)
        verifyAuthorization(.restricted, .unauthorized)
    }
    
    func testUpdateOnSignificantLocationChange()
    {
        let operation = { self.service.locationManager(self.locationManager, didUpdateLocations: []) }
        
        verifyLocationUpdate(expected: loremCity, operation)
        verifyLocationUpdate(expected: loremCity, operation, inverted: true)
        verifyLocationUpdate(expected: ipsumCity, operation)
        verifyLocationUpdate(expected: nil, operation)
    }
    
    func testLocationUpdateOnAppActivationWhenAuthorized()
    {
        let operation = { NotificationCenter.default.post(name: .UIApplicationDidBecomeActive, object: nil) }
        verifyAuthorization(.authorizedWhenInUse, .whenInUse)
        
        verifyLocationUpdate(expected: loremCity, operation)
        verifyLocationUpdate(expected: loremCity, operation, inverted: true)
        verifyLocationUpdate(expected: ipsumCity, operation)
        verifyLocationUpdate(expected: nil, operation)
    }
    
    func testLocationUpdateOnAppActivationWhenUnauthorized()
    {
        let operation = { NotificationCenter.default.post(name: .UIApplicationDidBecomeActive, object: nil) }
        
        verifyAuthorization(.denied, .unauthorized)
        verifyLocationUpdate(expected: nil, operation, inverted: true)
    }
    
    func testLocationUpdateWhenGeocodingFailure()
    {
        verifyLocationUpdate(expected: loremCity, {
            self.service.locationManager(self.locationManager, didUpdateLocations: [])
        })
        
        verifyLocationUpdate(expected: nil, {
            self.locationManager.mockLocation = CLLocation()
            self.service.locationManager(self.locationManager, didUpdateLocations: [])
        })
    }
    
    func testLocationUpdateWhenFailure()
    {
        verifyLocationUpdate(expected: loremCity, {
            self.service.locationManager(self.locationManager, didUpdateLocations: [])
        })
        
        verifyLocationUpdate(expected: nil, {
            self.locationManager.mockLocation = CLLocation()
            self.service.locationManager(self.locationManager, didFailWithError: NSError(domain: "", code: 1, userInfo: nil))
        })
    }
    
    func testLocationRequestPromiseWhenDetectionSuccess()
    {
        verifyLocationRequestPromise(expected: .success(loremCity), {
            self.service.locationManager(self.locationManager, didUpdateLocations: [])
        })
    }
    
    func testLocationRequestPromiseWhenDetectionFailure()
    {
        verifyAuthorization(.authorizedWhenInUse, .whenInUse)
        verifyLocationRequestPromise(expected: .failure(.locationNotFound), {
            self.service.locationManager(self.locationManager, didFailWithError: NSError(domain: "", code: 1, userInfo: nil))
        })
    }

    func testLocationRequestPromiseWhenNoAuthorization()
    {
        verifyAuthorization(.denied, .unauthorized)
        verifyLocationRequestPromise(expected: .failure(.locationServicesDisabled), {
            self.service.locationManager(self.locationManager, didChangeAuthorization: .denied)
        })
    }
    
    func testLocationRequestPromiseWhenFullfilledBeforeObserved()
    {
        verifyLocationUpdate(expected: loremCity, {
            self.service.locationManager(self.locationManager, didUpdateLocations: [])
        })
        
        verifyLocationRequestPromise(expected: .success(loremCity), {
            self.service.locationManager(self.locationManager, didUpdateLocations: [])
        })
    }
}

extension MMTCoreLocationServiceTests
{
    // MARK: Helper methods
    func verifyAuthorization(_ authorization: CLAuthorizationStatus, _ status: MMTLocationAuthStatus)
    {
        let authNotificationTrigger = expectation(forNotification: .locationAuthChangedNotification, object: nil, handler: nil)
        service.locationManager(locationManager, didChangeAuthorization: authorization)
        
        wait(for: [authNotificationTrigger], timeout: 0.5)
        XCTAssertEqual(service.authorizationStatus, status)
    }
    
    func verifyLocationUpdate(expected city: MMTCityProt?, _ operation: @escaping () -> Void, inverted: Bool = false)
    {
        let
        expectNotification = expectation(forNotification: .locationChangedNotification, object: nil, handler: nil)
        expectNotification.isInverted = inverted
        
        if let aCity = city {
            locationManager.mockLocation = aCity.location
            citiesStore.currentCity = .success(aCity)
        } else {
            locationManager.mockLocation = nil
            citiesStore.currentCity = .failure(.locationNotFound)
        }
        
        operation()
        wait(for: [expectNotification], timeout: 0.5)
        XCTAssertEqual(service.location, city)
    }
    
    func verifyLocationRequestPromise(expected result: MMTResult<MMTCityProt>, _ operation: @escaping () -> Void)
    {
        let completion = expectation(description: "Completion expectation")
        
        if case let .success(city) = result {
            locationManager.mockLocation = city.location
        }
        
        citiesStore.currentCity = result
        service.requestLocation().observe {
            XCTAssertEqual($0, result)
            completion.fulfill()
        }
        
        operation()
        wait(for: [completion], timeout: 0.5)
    }
}
