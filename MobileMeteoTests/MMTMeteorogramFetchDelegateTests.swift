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
    
    // MARK: Callback test methods
    
    func testFinishCallback()
    {
        let finishCallbackExpectation = expectationWithDescription("Finish callback expectation")
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL(), completion: {(var image: NSData?, var error: NSError?) in
            
            finishCallbackExpectation.fulfill()
        })
    
        delegate.connectionDidFinishLoading(NSURLConnection())
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFinishCallbackResponse()
    {
        let data = NSData(data: NSMutableData(length: 100)!)
        let finishCallbackExpectation = expectationWithDescription("Finish callback expectation")
    
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL(), completion: {(var image: NSData?, var error: NSError?) in
    
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
    
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL()) {
            (var image: NSData?, var error: NSError?) in
    
            XCTAssertNil(error)
            XCTAssertNotNil(image)
            XCTAssertEqual(image!, responseData)
            finishCallbackExpectation.fulfill()
        };
    
        delegate.connection(connection, didReceiveData: partOfResponse)
        delegate.connection(connection, didReceiveData: partOfResponse)
        delegate.connection(connection, didReceiveData: partOfResponse)
        delegate.connectionDidFinishLoading(NSURLConnection())
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFinishCallbackForUnpreparedMeteorogram()
    {
        let response = NSData(data: NSMutableData(length: 71)!)
        let finishCallbackExpectation = expectationWithDescription("Finish callback expectation")
        
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL()) {
            (var image: NSData?, var error: NSError?) in
            
            XCTAssertNil(image)
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.domain, MMTErrorDomain)
            XCTAssertEqual(error!.code, MMTError.MeteorogramNotFound.rawValue)
            
            finishCallbackExpectation.fulfill()
        }
        
        delegate.connection(connection, didReceiveData: response)
        delegate.connectionDidFinishLoading(NSURLConnection())
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    // MARK: Delegate test methods    
    
    func testConnectionFailedWithError()
    {
        let finishCallbackExpectation = expectationWithDescription("Finish callback expectation")
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL()) {
            (var image: NSData?, var error: NSError?) in
            
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.domain, MMTErrorDomain)
            XCTAssertEqual(error!.code, MMTError.MeteorogramFetchFailure.rawValue)
            
            finishCallbackExpectation.fulfill()
        };
    
        delegate.connection(connection, didFailWithError: NSError(domain: "domain", code: 1, userInfo: nil))
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}