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
import Contacts
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
        cityGeocoder = MMTCityGeocoder(general: generalGeocoder)
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
        
        generalGeocoder.result = .success([placemark])
        
        cityGeocoder.city(for: CLLocation()) {
            guard case let .success(city) = $0 else { XCTFail(); return }
            expect.fulfill()
            XCTAssertEqual(city.name, "City")
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFindCityForLocationWithError()
    {
        generalGeocoder.result = .failure(.mailNotAvailable)
        
        MMTAssertLocationGeocodeFailed(with: .locationNotFound)
    }

    func testFindCityForLocationWithEmptyResponse()
    {
        generalGeocoder.result = .success([])
        
        MMTAssertLocationGeocodeFailed(with: .locationNotFound)
    }
    
    func testFindCityForLocationWithInvalidPlacemark()
    {
        let placemark = MMTMockPlacemark(name: nil, locality: nil, ocean: nil, location: CLLocation(), administrativeArea: nil)
        generalGeocoder.result = .success([placemark])
        
        MMTAssertLocationGeocodeFailed(with: .locationUnsupported)
    }
    
    // MARK: Geocoding with criteria test methods
    
    func testFindCitiesForCriteria()
    {
        let validPlacemark = MMTMockPlacemark(name: "City", locality: nil, ocean: nil, location: CLLocation(), administrativeArea: "Some District")
        let invalidPlacemark = MMTMockPlacemark(name: nil, locality: nil, ocean: nil, location: CLLocation(), administrativeArea: nil)
        
        generalGeocoder.result = .success([validPlacemark, invalidPlacemark, invalidPlacemark, validPlacemark])
        
        MMTAssertCriteriaGeocodeResult(count: 2)
    }
    
    func testFindCitiesForCriteriaWithError()
    {
        generalGeocoder.result = .failure(.mailNotAvailable)
        MMTAssertCriteriaGeocodeResult(count: 0)
    }
    
    func testFindCitiesForCriteriaWithEmptyResult()
    {
        generalGeocoder.result = .success([])
        MMTAssertCriteriaGeocodeResult(count: 0)
    }
    
    func testFindCitiesForCriteriaWithInvalidPlacemarks()
    {
        let placemark = MMTMockPlacemark(name: nil, locality: nil, ocean: nil, location: CLLocation(), administrativeArea: nil)
        
        generalGeocoder.result = .success([placemark, placemark])
        MMTAssertCriteriaGeocodeResult(count: 0)
    }
    
    // MARK: Assertions
    
    func MMTAssertLocationGeocodeFailed(with error: MMTError, file: StaticString = #file, line: UInt = #line)
    {
        let expect = expectation(description: "geocode finished")
        
        cityGeocoder.city(for: CLLocation()) {
            guard case let .failure(err) = $0 else { XCTFail(); return }
            expect.fulfill()
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
        var result: MMTResult<[MMTPlacemark]>!
        
        // MARK: Mocked methods
        
        func geocode(location: CLLocation, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
        {
            completion(result)
        }
        
        func geocode(address: CNPostalAddress, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
        {
            completion(result)
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
