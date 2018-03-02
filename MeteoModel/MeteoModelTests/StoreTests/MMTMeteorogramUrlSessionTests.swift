//
//  MMTMeteorogramUrlSessionTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 04.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
@testable import MeteoModel

class MMTMeteorogramUrlSessionTests: XCTestCase
{
    var session: MMTMeteorogramUrlSession!
    var url = URL(string: "http://example.com")!
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        session = MMTMeteorogramUrlSession(redirectionBaseUrl: nil)
    }
    
    override func tearDown()
    {
        session = nil
        super.tearDown()
    }
    
    // MARK: Test methods for fetching HTML
    func testFetchHTML()
    {
        let html = "<html><head></head><body>Lorem ipsum</body></html>"
        let session = MMTMockMeteorogramUrlSession(html.data(using: .windowsCP1250), nil, nil)
        
        session.fetchHTMLContent(from: url, encoding: .utf8) { (htmlResult, error) in
            XCTAssertEqual(html, htmlResult)
            XCTAssertNil(error)
        }
    }
    
    func testFetchHTMLWithError()
    {
        let session = MMTMockMeteorogramUrlSession(nil, nil, NSError())
        
        session.fetchHTMLContent(from: url, encoding: .utf8) { (html, error) in
            XCTAssertEqual(error, MMTError.htmlFetchFailure)
            XCTAssertNil(html)
        }
    }
    
    func testFetchHTMLWithEmptyInput()
    {
        let session = MMTMockMeteorogramUrlSession(nil, nil, nil)
        
        session.fetchHTMLContent(from: url, encoding: .utf8) { (html, error) in
            XCTAssertEqual(error, MMTError.htmlFetchFailure)
            XCTAssertNil(html)
        }
    }

    // MARK: Test methods for fetching images
    func testFetchImage()
    {
        let image = UIImagePNGRepresentation(.from(color: .blue))
        let sesstion = MMTMockMeteorogramUrlSession(image, nil, nil)

        sesstion.fetchImageFromUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertNotNil(image)
            XCTAssertNil(error)
        }
    }

    func testFetchImageWithError()
    {
        let sesstion = MMTMockMeteorogramUrlSession(nil, nil, NSError())

        sesstion.fetchImageFromUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
            XCTAssertNil(image)
        }
    }

    func testFetchImageWithInvalidData()
    {
        let sesstion = MMTMockMeteorogramUrlSession(Data(), nil, nil)

        sesstion.fetchImageFromUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
            XCTAssertNil(image)
        }
    }

    // MARK: Test methods for fetching meteorograms
    func testFetchMeteorogramImage()
    {        
        let image = UIImagePNGRepresentation(.from(color: .red))
        let sesstion = MMTMockMeteorogramUrlSession(image, nil, nil)

        sesstion.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertNotNil(image)
            XCTAssertNil(error)
        }
    }

    func testFetchMeteorogramImageWithInvalidData()
    {
        let sesstion = MMTMockMeteorogramUrlSession(Data(), nil, nil)

        sesstion.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
            XCTAssertNil(image)
        }
    }

    func testFetchMeteorogramImageWithError()
    {
        let sesstion = MMTMockMeteorogramUrlSession(nil, nil, NSError())

        sesstion.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
            XCTAssertNil(image)
        }
    }

    func testFetchMeteorogramImageWithNoRedirection()
    {
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let sesstion = MMTMockMeteorogramUrlSession(nil, response, nil)

        sesstion.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
            XCTAssertNil(image)
        }
    }

    // MARK: Test methods for handling redirection
    func testHandlingOfRedirection()
    {
        let req = URLRequest(url: URL(string: "http://lorem-ipsum.com?aaa=bbb&ccc=dddd")!)
        let session = MMTMockMeteorogramUrlSession(nil, nil, nil)

        session.urlSession(URLSession(), task: MMTMockTask(), willPerformHTTPRedirection: HTTPURLResponse(), newRequest: req) {
            XCTAssertEqual($0?.url?.absoluteString, "http://example.com?aaa=bbb&ccc=dddd")
        }
    }

    func testHandlingOfRedirectionWhenRedirectionUrlIsNil()
    {
        var
        req = URLRequest(url: URL(string: "example.com")!)
        req.url = nil

        let session = MMTMockMeteorogramUrlSession(nil, nil, nil)

        session.urlSession(URLSession(), task: MMTMockTask(), willPerformHTTPRedirection: HTTPURLResponse(), newRequest: req) {
            XCTAssertNil($0)
        }
    }

    func testHandlingOfRedirectionWhenRedirectionUrlIsInvalid()
    {
        let req = URLRequest(url: URL(string: "example.com")!)
        let session = MMTMockMeteorogramUrlSession(nil, nil, nil)

        session.urlSession(URLSession(), task: MMTMockTask(), willPerformHTTPRedirection: HTTPURLResponse(), newRequest: req) {
            XCTAssertNil($0)
        }
    }
}

fileprivate extension UIImage
{
    static func from(color: UIColor) -> UIImage
    {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
