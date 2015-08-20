//
//  MMTMeteorogramRedirectionFetchDelegateTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
import MobileMeteo

class MMTMeteorogramRedirectionFetchDelegateTests: XCTestCase
{
    // MARK: Properties
    
    var connection: NSURLConnection!
    var idleClosure: MMTFetchMeteorogramCompletion!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp();
        connection = NSURLConnection();
        idleClosure = {(var image: NSData?, var error: NSError?) in }
    }
    
    override func tearDown()
    {
        connection = nil;
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func testConnectionWillSendRequest()
    {
        let url = NSURL(string: "http://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&row=367&col=227&lang=pl&fdate=2015060812")!
        let request = NSURLRequest(URL: url)
        
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL(), completion: idleClosure)
        let req = delegate.connection(connection, willSendRequest: request, redirectResponse: nil)
        
        XCTAssertEqual(url.absoluteString!, req!.URL!.absoluteString!);
    }
    
    func testRedirectionRequestForModelUm()
    {
        let expectedUrl = "http://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&row=367&col=227&lang=pl&fdate=2015060812"
        
        let url = NSURL(string: "http://www.meteo.pl/um/php/mgram_search.php?NALL=53.585869&EALL=19.570815&lang=pl&fdate=2015060812")
        let redirectResponse = NSHTTPURLResponse(URL: url!, statusCode: 301, HTTPVersion: "1.1", headerFields: [
            "Location": "./meteorogram_map_um.php?ntype=0u&row=367&col=227&lang=pl&fdate=2015060812"
            ])
        
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL.mmt_modelUmDownloadBaseUrl(), completion: idleClosure)
        let request = delegate.connection(connection, willSendRequest: NSURLRequest(), redirectResponse: redirectResponse)
        
        XCTAssertEqual(expectedUrl, request!.URL!.absoluteString!);
    }
    
    func testRedirectionRequestForModelCoamps()
    {
        let expectedUrl = "http://www.meteo.pl/metco/mgram_pict.php?ntype=2n&fdate=2015071900&row=127&col=83&lang=pl"
        
        let url = NSURL(string: "http://www.meteo.pl/php/mgram_search.php?NALL=53.014417&EALL=18.598111&lang=pl&fdate=2015071900")
        let redirectResponse = NSHTTPURLResponse(URL: url!, statusCode: 301, HTTPVersion: "1.1", headerFields: [
            "Location": "./meteorogram_map.php?ntype=2n&fdate=2015071900&row=127&col=83&lang=pl"
            ])
        
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL.mmt_modelCoampsDownloadBaseUrl(), completion: idleClosure)
        let request = delegate.connection(connection, willSendRequest: NSURLRequest(), redirectResponse: redirectResponse)
        
        XCTAssertEqual(expectedUrl, request!.URL!.absoluteString!);
    }
}