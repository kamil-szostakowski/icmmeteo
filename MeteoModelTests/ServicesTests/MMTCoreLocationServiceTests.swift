//
//  MMTCoreLocationServiceTests.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 28.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
@testable import MeteoModel

class MMTCoreLocationServiceTests: XCTestCase
{
    // MARK: Properties
    var service: MMTCoreLocationService!
    var locationManager: CLLocationManager!
    var analytics: MMTMockAnalytics!
    let notification: Notification.Name = .locationChangedNotification
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        locationManager = CLLocationManager()
        analytics = MMTMockAnalytics()
        analytics.category = .Locations
        
        service = MMTCoreLocationService(locationManager: locationManager)
        service.analytics = analytics
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
    
    func testAlwaysAuthorizationSuccess()
    {
        analytics.action = .LocationDidAllowAlways
        service.locationManager(locationManager, didChangeAuthorization: .authorizedAlways)
        
        XCTAssertEqual(service.authorizationStatus, .always)
    }
    
    func testWhenInUseAuthorizationSuccess()
    {
        analytics.action = .LocationDidAllowWhenUsing
        service.locationManager(locationManager, didChangeAuthorization: .authorizedWhenInUse)
        
        XCTAssertEqual(service.authorizationStatus, .whenInUse)
    }
    
    func testAuthorizationFailure()
    {
        let unauthorizedStatuse: [CLAuthorizationStatus] = [.notDetermined, .denied, .restricted]

        for status in unauthorizedStatuse
        {
            analytics.action = .LocationDidAllowNever
            service.locationManager(locationManager, didChangeAuthorization: status)
            XCTAssertEqual(service.authorizationStatus, .unauthorized)
        }
    }
    
    func testLocationUpdateOnSignificantLocationChange()
    {
        let expectNotification = expectation(forNotification: notification, object: nil, handler: nil)
        
        analytics.action = .LocationDidAllowAlways
        service.locationManager(locationManager, didChangeAuthorization: .authorizedAlways)
        
        wait(for: [expectNotification], timeout: 1)
    }
    
    func testLocationUpdateOnAppActivation()
    {
        analytics.action = .LocationDidAllowWhenUsing
        service.locationManager(locationManager, didChangeAuthorization: .authorizedWhenInUse)
        
        let expectNotification = expectation(forNotification: notification, object: nil, handler: nil)
        NotificationCenter.default.post(name: .UIApplicationDidBecomeActive, object: nil)
        wait(for: [expectNotification], timeout: 1)
    }
    
    func testLocationUpdateOnAppActivationWhenUnauthorized()
    {
        let
        expectNotification = expectation(forNotification: notification, object: nil, handler: nil)
        expectNotification.isInverted = true
        
        NotificationCenter.default.post(name: .UIApplicationDidBecomeActive, object: nil)
        wait(for: [expectNotification], timeout: 1)
    }
}
