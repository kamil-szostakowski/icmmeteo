//
//  MMTCityTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 17.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
@testable import MobileMeteo

class MMTCityTests: XCTestCase
{
    let location = CLLocation(latitude: 12.1212, longitude: 13.1313)
    
    // MARK: Test methods
    
    func testDesignatedInitializer()
    {
        MMTVerifyCity(MMTCity(name: "City Name", region: "Some District", location: location))
    }
    
    func testInitializerForPlacemark()
    {
        let city1 = MMTCity(placemark: MMTTestPlacemark(nil, "City Name", nil, location, "Some District"))
        
        XCTAssertNotNil(city1)
        MMTVerifyCity(city1!)
        
        let city2 = MMTCity(placemark: MMTTestPlacemark("City Name", nil, nil, location, "Some District"))
        
        XCTAssertNotNil(city2)
        MMTVerifyCity(city2!)
    }
    
    func testInitializerForPlacemarkWithoutAdministrativeArea()
    {
        XCTAssertNil(MMTCity(placemark: MMTTestPlacemark(nil, "City Name", nil, location, nil)))
    }
    
    func testInitializerForPlacemarkWithoutName()
    {
        XCTAssertNil(MMTCity(placemark: MMTTestPlacemark(nil, nil, nil, location, "Some District")))
    }
    
    func testInitializerForPlacemarkWithoutLocation()
    {
        XCTAssertNil(MMTCity(placemark: MMTTestPlacemark("City Name", nil, nil, nil, "Some District")))
    }
    
    func testInitializerForPlacemarkWithOcean()
    {
        XCTAssertNil(MMTCity(placemark: MMTTestPlacemark("City Name", nil, "Baltic Sea", location, "Some District")))
    }
    
    func testLocationProperty()
    {
        let city = MMTCity(name: "City Name", region: "Some District", location: location)
        let newLocation = CLLocation(latitude: 14.1414, longitude: 15.1515)
        
        XCTAssertEqual(location.coordinate.latitude, city.location.coordinate.latitude)
        XCTAssertEqual(location.coordinate.longitude, city.location.coordinate.longitude)
        
        city.location = newLocation
        
        XCTAssertEqual(newLocation.coordinate.latitude, city.location.coordinate.latitude)
        XCTAssertEqual(newLocation.coordinate.longitude, city.location.coordinate.longitude)
    }
    
    func testFavouriteProperty()
    {
        let city = MMTCity(name: "City Name", region: "Some District", location: location)
        XCTAssertFalse(city.isFavourite)
        
        city.isFavourite = true
        XCTAssertTrue(city.isFavourite)
    }
    
    func testCapitalProperty()
    {
        let city = MMTCity(name: "City Name", region: "Some District", location: location)
        XCTAssertFalse(city.isCapital)
        
        city.isCapital = true
        XCTAssertTrue(city.isCapital)
    }
    
    // MARK: Helpers
    
    private func MMTVerifyCity(city: MMTCity)
    {
        XCTAssertEqual("City Name", city.name)
        XCTAssertEqual("Some District", city.region)
        XCTAssertEqual(location.coordinate.latitude, city.location.coordinate.latitude)
        XCTAssertEqual(location.coordinate.longitude, city.location.coordinate.longitude)
        XCTAssertFalse(city.isFavourite)
        XCTAssertFalse(city.isCapital)
    }
    
    private struct MMTTestPlacemark: MMTPlacemark
    {
        var name: String?
        var locality: String?
        var ocean: String?
        var location: CLLocation?
        var administrativeArea: String?
        
        init(_ name: String?, _ locality: String?, _ ocean: String?, _ location: CLLocation?, _ administrativeArea: String?)
        {
            self.name = name
            self.locality = locality
            self.ocean = ocean
            self.location = location
            self.administrativeArea = administrativeArea
        }
    }
}
