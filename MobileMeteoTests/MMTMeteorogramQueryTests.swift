//
//  MMTMeteorogramQueryTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 30.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
import MobileMeteo

class MMTMeteorogramQueryTests : XCTestCase
{
    // MARK: Setup
    
    var location : CLLocation!
    var formatter : NSDateFormatter!
    
    override func setUp()
    {
        super.setUp()
        
        location = CLLocation(latitude: 53.03, longitude: 18.57)
        formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT:7200)
    }
    
    override func tearDown()
    {
        location = nil;
        formatter = nil;
        
        super.tearDown()
    }
    
    // MARK: Test methods    
    
    func testDate()
    {
        let date = formatter.dateFromString("2015-04-15T10:00")!
        let query = MMTMeteorogramQuery(location:location, date: date, name: nil)
        
        XCTAssertEqual(date, query.date)
    }
    
    func testCoordinate()
    {
        let query = MMTMeteorogramQuery(location:location)
    
        XCTAssertEqual(53.03, query.location.coordinate.latitude)
        XCTAssertEqual(18.57, query.location.coordinate.longitude)
    }
    
    func testName()
    {
        let query = MMTMeteorogramQuery(location: location, name: "Example")
        
        XCTAssertEqual("Example", query.locationName!)
    }        
}