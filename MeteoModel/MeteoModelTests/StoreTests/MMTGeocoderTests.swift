//
//  MMTGeocoderTests.swift
//  MobileMeteo
//
//  Created by Kamil on 18.02.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import XCTest
import MapKit
import CoreLocation
@testable import MeteoModel

class MMTGeocoderTests: XCTestCase
{
    var cityGeocoder: MMTCityGeocoder!
    var generalGeocoder: MMTMockGeocoder!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        generalGeocoder = MMTMockGeocoder()
        cityGeocoder = MMTCityGeocoder(general: generalGeocoder, factory: MMTMockEntityFactory())
    }
    
    override func tearDown()
    {
        cityGeocoder = nil
        generalGeocoder = nil
        super.tearDown()
    }
    
    // MARK: Geocoding with location test methods
    
    func testFindCityForLocation()
    {
        let placemark = MMTMockPlacemark(name: "City", locality: nil, ocean: nil, location: CLLocation(), administrativeArea: "Some District")
        let expect = expectation(description: "geocode finished")
        
        generalGeocoder.placemarks = [placemark]
        
        cityGeocoder.city(for: CLLocation()) {
            (city: MMTCityProt?, error: MMTError?) in
            
            expect.fulfill()
            
            XCTAssertNil(error)
            XCTAssertNotNil(city)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFindCityForLocationWithError()
    {
        generalGeocoder.error = MMTError.mailNotAvailable
        
        MMTAssertLocationGeocodeFailed(with: .locationNotFound)
    }

    func testFindCityForLocationWithEmptyResponse()
    {
        generalGeocoder.placemarks = []
        
        MMTAssertLocationGeocodeFailed(with: .locationNotFound)
    }
    
    func testFindCityForLocationWithInvalidPlacemark()
    {
        let placemark = MMTMockPlacemark(name: nil, locality: nil, ocean: nil, location: CLLocation(), administrativeArea: nil)
        generalGeocoder.placemarks = [placemark]
        
        MMTAssertLocationGeocodeFailed(with: .locationUnsupported)
    }
    
    // MARK: Geocoding with criteria test methods
    
    func testFindCitiesForCriteria()
    {
        let validPlacemark = MMTMockPlacemark(name: "City", locality: nil, ocean: nil, location: CLLocation(), administrativeArea: "Some District")
        let invalidPlacemark = MMTMockPlacemark(name: nil, locality: nil, ocean: nil, location: CLLocation(), administrativeArea: nil)
        
        generalGeocoder.placemarks = [validPlacemark, invalidPlacemark, invalidPlacemark, validPlacemark]
        
        MMTAssertCriteriaGeocodeResult(count: 2)
    }
    
    func testFindCitiesForCriteriaWithError()
    {
        generalGeocoder.error = MMTError.mailNotAvailable
        MMTAssertCriteriaGeocodeResult(count: 0)
    }
    
    func testFindCitiesForCriteriaWithNilResult()
    {
        generalGeocoder.placemarks = nil
        MMTAssertCriteriaGeocodeResult(count: 0)
    }
    
    func testFindCitiesForCriteriaWithEmptyResult()
    {
        generalGeocoder.placemarks = []
        MMTAssertCriteriaGeocodeResult(count: 0)
    }
    
    func testFindCitiesForCriteriaWithInvalidPlacemarks()
    {
        let placemark = MMTMockPlacemark(name: nil, locality: nil, ocean: nil, location: CLLocation(), administrativeArea: nil)
        
        generalGeocoder.placemarks = [placemark, placemark]
        MMTAssertCriteriaGeocodeResult(count: 0)
    }
    
    // MARK: Assertions
    
    func MMTAssertLocationGeocodeFailed(with error: MMTError, file: StaticString = #file, line: UInt = #line)
    {
        let expect = expectation(description: "geocode finished")
        
        cityGeocoder.city(for: CLLocation()) {
            (city: MMTCityProt?, err: MMTError?) in
            
            expect.fulfill()
            
            XCTAssertNil(city, file: file, line: line)
            XCTAssertEqual(err, error, file: file, line: line)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func MMTAssertCriteriaGeocodeResult(count: Int, file: StaticString = #file, line: UInt = #line)
    {
        let expect = expectation(description: "geocode finished")
        
        cityGeocoder.cities(matching: "lorem ipsum") {
            (cities: [MMTCityProt]) in
            
            expect.fulfill()
            XCTAssertEqual(cities.count, count, file: file, line: line)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: Mocks
    
    class MMTMockGeocoder: MMTGeocoder
    {
        var placemarks: [MMTPlacemark]?
        var error: Error?
        
        // MARK: Mocked methods
        
        func geocode(location: CLLocation, completion: @escaping MMTGeocodeCompletion)
        {
            completion(placemarks, error)
        }
        
        func geocode(addressDictionary: [AnyHashable : Any], completion: @escaping MMTGeocodeCompletion)
        {
            completion(placemarks, error)
        }
        
        func cancelGeocode()
        {
        }
    }
    
    struct MMTMockPlacemark: MMTPlacemark
    {
        var name: String?
        var locality: String?
        var ocean: String?
        var location: CLLocation?
        var administrativeArea: String?
    }
}
