//
//  MMTExtensionNSURLTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import MobileMeteo
import CoreLocation

class MMTCategoryNSURLTests: XCTestCase
{
    // MARK: Test methods
    
    func testBaseUrl()
    {
        XCTAssertEqual("http://www.meteo.pl", NSURL.mmt_baseUrl().absoluteString!)
    }
    
    // MARK: Model um related tests
    
    func testModelUmDownloadBaseUrl()
    {
        XCTAssertEqual("http://www.meteo.pl/um/metco/mgram_pict.php", NSURL.mmt_modelUmDownloadBaseUrl().absoluteString!);
    }
    
    func testModelUmSearchUrl()
    {
        let expectedUrl = "http://www.meteo.pl/um/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl&fdate=2015060800"
        
        let location = CLLocation(latitude: 53.585869, longitude: 19.570815)
        let date = TT.utcFormatter.dateFromString("2015-06-08T00:00")!
        
        XCTAssertEqual(expectedUrl, NSURL.mmt_modelUmSearchUrl(location, tZero: date).absoluteString!);
    }
    
    // MARK: Model coamps related tests
    
    func testModelCoampsDownloadBaseUrl()
    {        
        XCTAssertEqual("http://www.meteo.pl/metco/mgram_pict.php", NSURL.mmt_modelCoampsDownloadBaseUrl().absoluteString!);
    }
    
    func testModelCoampsSearchUrl()
    {
        let expectedUrl = "http://www.meteo.pl/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl&fdate=2015060712"
        
        let location = CLLocation(latitude: 53.585869, longitude: 19.570815)
        let date = TT.utcFormatter.dateFromString("2015-06-07T12:00")!
        
        XCTAssertEqual(expectedUrl, NSURL.mmt_modelCoampsSearchUrl(location, tZero: date).absoluteString!);
    }
}