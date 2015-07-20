//
//  MMTCategoryNSURLTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 30.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
import MobileMeteo

class MMTCategoryNSURLTests : XCTestCase
{
    func testBaseUrl()
    {
        XCTAssertEqual("http://www.meteo.pl", NSURL.mmt_baseUrl().absoluteString!);
    }    
    
    func testModelUmDownloadUrl()
    {        
        XCTAssertEqual("http://www.meteo.pl/um/metco/mgram_pict.php", NSURL.mmt_meteorogramDownloadBaseUrl(.UM).absoluteString!);
    }
    
    func testModelCoampsDownloadUrl()
    {
        XCTAssertEqual("http://www.meteo.pl/metco/mgram_pict.php", NSURL.mmt_meteorogramDownloadBaseUrl(.COAMPS).absoluteString!);
    }
    
    func testModelUmSearchUrl()
    {
        class MockQuery: MMTMeteorogramQuery
        {
            override var location: CLLocation { return CLLocation(latitude: 53.585869, longitude: 19.570815) }
            override var date: String { return "2015060812" }
            override var type: MMTModelType { return .UM }
        }
        
        let expectedUrl = "http://www.meteo.pl/um/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl&fdate=2015060812"
        let mockQuery = MockQuery(location: CLLocation(), type: .UM)
        
        XCTAssertEqual(expectedUrl, NSURL.mmt_meteorogramSearchUrlWithQuery(mockQuery).absoluteString!);
    }
    
    func testModelCoampsSearchUrl()
    {
        class MockQuery: MMTMeteorogramQuery
        {
            override var location: CLLocation { return CLLocation(latitude: 53.585869, longitude: 19.570815) }
            override var date: String { return "2015060812" }
            override var type: MMTModelType { return .COAMPS }
        }
        
        let expectedUrl = "http://www.meteo.pl/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl&fdate=2015060812"
        let mockQuery = MockQuery(location: CLLocation(), type: .COAMPS)
        
        XCTAssertEqual(expectedUrl, NSURL.mmt_meteorogramSearchUrlWithQuery(mockQuery).absoluteString!);
    }
}