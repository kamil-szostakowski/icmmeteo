//
//  MMTMeteorogramFetchDelegateTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 30.06.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
import MobileMeteo

class MMTMeteorogramFetchDelegateTests : XCTestCase
{
    var connection: NSURLConnection!
    var idleClosure: MMTFetchMeteorogramCompletion!
    
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
    
    // MARK: Callback test methods
    
    func testFinishCallback()
    {
        let finishCallbackExpectation = expectationWithDescription("Finish callback expectation")
        let delegate = MMTMeteorogramFetchDelegate(url: NSURL(), completion: {(var image: NSData?, var error: NSError?) in
            
            finishCallbackExpectation.fulfill()
        })
    
        delegate.connectionDidFinishLoading(NSURLConnection())
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFinishCallbackResponse()
    {
        let data = NSData(data: NSMutableData(length: 100)!)
        let finishCallbackExpectation = expectationWithDescription("Finish callback expectation")
    
        let delegate = MMTMeteorogramFetchDelegate(url: NSURL(), completion: {(var image: NSData?, var error: NSError?) in
    
            XCTAssertNil(error);
            XCTAssertNotNil(image);
            XCTAssertEqual(image!, data);
        
            finishCallbackExpectation.fulfill();
        });
    
        delegate.connection(connection, didReceiveData: data)
        delegate.connectionDidFinishLoading(NSURLConnection())
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFinishCallbackForMultipartResponse()
    {
        let partOfResponse = NSData(data: NSMutableData(length: 100)!)
        let responseData = NSData(data: NSMutableData(length: 300)!)
        let finishCallbackExpectation = expectationWithDescription("Finish callback expectation")
    
        let delegate = MMTMeteorogramFetchDelegate(url: NSURL(), completion: {(var image: NSData?, var error: NSError?) in
    
            XCTAssertNil(error)
            XCTAssertNotNil(image)
            XCTAssertEqual(image!, responseData)
            finishCallbackExpectation.fulfill()
        });
    
        delegate.connection(connection, didReceiveData: partOfResponse)
        delegate.connection(connection, didReceiveData: partOfResponse)
        delegate.connection(connection, didReceiveData: partOfResponse)
        delegate.connectionDidFinishLoading(NSURLConnection())
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    // MARK: Delegate test methods
    
    func testConnectionWillSendRequest()
    {
        let url = NSURL(string: "http://www.meteo.pl/um/metco/mgram_pict.php?ntype=0u&row=367&col=227&lang=pl&fdate=2015060812")!
        let request = NSURLRequest(URL: url)
        
        let delegate = MMTMeteorogramFetchDelegate(url: NSURL(), completion: idleClosure)
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
    
        let delegate = MMTMeteorogramFetchDelegate(url: NSURL.mmt_modelUmDownloadBaseUrl(), completion: idleClosure)
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
        
        let delegate = MMTMeteorogramFetchDelegate(url: NSURL.mmt_modelCoampsDownloadBaseUrl(), completion: idleClosure)
        let request = delegate.connection(connection, willSendRequest: NSURLRequest(), redirectResponse: redirectResponse)
        
        XCTAssertEqual(expectedUrl, request!.URL!.absoluteString!);
    }
    
    func testConnectionFailedWithError()
    {
        let finishCallbackExpectation = expectationWithDescription("Finish callback expectation")
        let delegate = MMTMeteorogramFetchDelegate(url: NSURL(), completion: {(var image: NSData?, var error: NSError?) in
            
            if error != nil {
                finishCallbackExpectation.fulfill()
            }
        });
    
        delegate.connection(connection, didFailWithError: NSError(domain: "domain", code: 1, userInfo: nil))
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}