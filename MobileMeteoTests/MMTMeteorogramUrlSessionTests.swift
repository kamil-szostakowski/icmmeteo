//
//  MMTMeteorogramUrlSessionTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 04.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
@testable import MobileMeteo

class MMTMeteorogramUrlSessionTests: XCTestCase
{
    var session: MMTMeteorogramUrlSession!
    var url = URL(string: "http://example.com")!
    
    var validContent: String {
        return contentWithDateString("2014.10.15 12:34 UTC")
    }
    
    var invalidContent: String {
        return contentWithDateString("201.02.04 00:00 UT")
    }
    
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
    
    // MARK: Test methods for fetching forecast start date

    func testFetchForecastStartDate()
    {
        let session = MMTMockMeteorogramUrlSession(validContent.data(using: .windowsCP1250), nil, nil)

        session.fetchForecastStartDateFromUrl(url){
            (date: Date?, error: MMTError?) -> Void in

            XCTAssertEqual(date, TT.utcFormatter.date(from: "2014-10-15T12:34"))
        }
    }

    func testFetchForecastStartDateWithInvalidFormat()
    {
        let session = MMTMockMeteorogramUrlSession(invalidContent.data(using: .windowsCP1250), nil, nil)

        session.fetchForecastStartDateFromUrl(url){
            (date: Date?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.forecastStartDateNotFound)
        }
    }

    func testFetchForecastStartDateWithEmptyInput()
    {
        let session = MMTMockMeteorogramUrlSession(nil, nil, nil)

        session.fetchForecastStartDateFromUrl(url){
            (date: Date?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.forecastStartDateNotFound)
        }
    }

    // TODO: Implement custom assert
    func testFetchForecastStartDateWithInvalidEncoding()
    {
        let session = MMTMockMeteorogramUrlSession(validContent.data(using: .utf8), nil, nil)

        session.fetchForecastStartDateFromUrl(url){
            (date: Date?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.forecastStartDateNotFound)
        }
    }

    // MARK: Test methods for fetching images

    func testFetchImage()
    {
        let image = UIImagePNGRepresentation(UIImage(named: "detailed-maps")!)
        let sesstion = MMTMockMeteorogramUrlSession(image, nil, nil)

        sesstion.fetchImageFromUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertNotNil(image)
        }
    }

    func testFetchImageWithError()
    {
        let sesstion = MMTMockMeteorogramUrlSession(nil, nil, NSError())

        sesstion.fetchImageFromUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
        }
    }

    func testFetchImageWithInvalidData()
    {
        let sesstion = MMTMockMeteorogramUrlSession(Data(), nil, nil)

        sesstion.fetchImageFromUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
        }
    }

    // MARK: Test methods for fetching meteorograms

    func testFetchMeteorogramImage()
    {
        let image = UIImagePNGRepresentation(UIImage(named: "detailed-maps")!)
        let sesstion = MMTMockMeteorogramUrlSession(image, nil, nil)

        sesstion.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertNotNil(image)
        }
    }

    func testFetchMeteorogramImageWithInvalidData()
    {
        let sesstion = MMTMockMeteorogramUrlSession(Data(), nil, nil)

        sesstion.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
        }
    }

    func testFetchMeteorogramImageWithError()
    {
        let sesstion = MMTMockMeteorogramUrlSession(nil, nil, NSError())

        sesstion.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
        }
    }

    func testFetchMeteorogramImageWithNoRedirection()
    {
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let sesstion = MMTMockMeteorogramUrlSession(nil, response, nil)

        sesstion.fetchMeteorogramImageForUrl(url) {
            (image: UIImage?, error: MMTError?) -> Void in

            XCTAssertEqual(error, MMTError.meteorogramFetchFailure)
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

    // MARK: Helpers

    class MMTMockMeteorogramUrlSession: MMTMeteorogramUrlSession
    {
        let mockData: Data?
        let mockResponse: URLResponse?
        let mockError: Error?

        init(_ data: Data?, _ response: URLResponse?, _ error: Error?)
        {
            mockData = data
            mockResponse = response
            mockError = error

            super.init(redirectionBaseUrl: URL(string: "http://example.com")!, timeout: 60)
        }

        override func runTaskWithUrl(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
        {
            completion(mockData, mockResponse, mockError)
        }
    }

    class MMTMockTask: URLSessionTask
    {
        override func cancel() {}
    }

    func contentWithDateString(_ dateString: String) -> String
    {
        return "<div style=\"position: absolute; left: 0px; top: 0px; padding: 0px; margin: 0px; width: 100%; height: 80px; background-color:  #edc389;\"><div class=\"info_model\" id=\"info_coamps\"><table border=0 cellspacing=5 cellpadding=5><tr valign=middle><td><font style='color:#8d6329; font-size: 32px; font-weight: 700'>MODEL UM</font></td><td><font style='color: #7d5319;'>Siatka: 4km. Długość prognozy 60h. </font><br><font class='start_data'>start prognozy t<sub>0</sub> : \(dateString)</font></td><td onMouseOver=\"this.style.cursor='pointer';\" onClick=\"loadModel(0,1)\"><div style=\"background-color: #ddb379; border: 1px solid #ad8349\"><table border=0 cellspacing=0 cellpadding=0><tr><td><img src=\"/web_pict/refresh-32.png\" style=\"margin: 4px\"></td><td style='font-family: Arial; font-size: 9px; font-weight: 700; color:#444; padding: 5px'>załaduj<br>najnowszą prognozę</td></tr></table></div></td></tr></table></div><div style=\"position: absolute; left 0px; bottom: 0px; padding: 0px; margin: 0px; width: 100%;  border: 1px solid #cda369; border-left: 0px; border-right: 0px; background-color: #ddb379\"><font style='color: #ffffff; font-weight: 700;'><A class=\"navi_um\"></A><A class=\"navi_um\" href=\"javascript:loadDIV('meteorogram_um','kon_3c_b',0);\">METEOROGRAMY</A> | <A class=\"navi_um\" href=\"javascript:loadDIV('szczegolowe_um','kon_3c_b',0);\">MAPY SZCZEGÓŁOWE</A></div></div>"
    }
}
