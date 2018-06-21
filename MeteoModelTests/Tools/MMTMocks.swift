//
//  MMTStubs.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 02.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import XCTest
import Foundation
import CoreLocation
@testable import MeteoModel

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
    
    override func runTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        completion(mockData, mockResponse, mockError)
    }
}

class MMTMockTask: URLSessionTask
{
    override func cancel() {}
}

class MMTMockForecastStore : MMTForecastStore
{
    var result: (Date?, MMTError?)?
    
    func startDate(_ completion: @escaping (Date?, MMTError?) -> Void) {
        DispatchQueue.main.async {
            completion(self.result!.0, self.result!.1)
        }
    }
}

class MMTMockMeteorogramImageStore : MMTMeteorogramImageStore
{
    var meteorogramResult: (UIImage?, MMTError?)?
    var mapResult: [(UIImage?, MMTError?)]?
    var legendResult: (UIImage?, MMTError?)?
    
    var climateModel: MMTClimateModel {
        return MMTUmClimateModel()
    }
    
    func getMeteorogram(for city: MMTCityProt, startDate: Date, completion: @escaping (UIImage?, MMTError?) -> Void) {
        DispatchQueue.main.async {
            completion(self.meteorogramResult!.0, self.meteorogramResult!.1)
        }
    }
    
    func getLegend(_ completion: @escaping (UIImage?, MMTError?) -> Void) {
        DispatchQueue.main.async {
            completion(self.legendResult!.0, self.legendResult!.1)
        }
    }
    
    func getMeteorogram(for map: MMTDetailedMap, moment: Date, startDate: Date, completion: @escaping (UIImage?, MMTError?) -> Void) {
        DispatchQueue.main.async {
            let result = self.mapResult!.popLast()!
            completion(result.0, result.1)
        }
    }
}

class MMTMockMeteorogramStore: MMTMeteorogramDataStore
{
    var climateModel: MMTClimateModel = MMTUmClimateModel()
    var mapMeteorogram: MMTMapMeteorogram?
    var meteorogram: MMTMeteorogram?
    var error: MMTError?
    
    func meteorogram(for city: MMTCityProt, completion: @escaping (MMTMeteorogram?, MMTError?) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.meteorogram, self.error)
        }
    }
    
    func meteorogram(for map: MMTDetailedMap, completion: @escaping (MMTMapMeteorogram?, MMTError?) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.mapMeteorogram, self.error)
        }
    }
}

class MMTMockModelControllerDelegate<T>: MMTModelControllerDelegate where T: MMTModelController
{
    var updateCallbacks = [(T) -> Void]()
    var updatesCount: Int = 0
    
    func onModelUpdate(_ controller: MMTModelController)
    {
        if updatesCount < updateCallbacks.count {
            updatesCount += 1
            updateCallbacks[updatesCount-1](controller as! T)
        }
    }
    
    func awaitModelUpdate(completions: [(T) -> Void]) -> [XCTestExpectation]
    {
        var updateExpectations = [XCTestExpectation]()
        
        updateCallbacks = [{ _ in XCTFail("Too many updates") }]
        
        for completion in completions.reversed()
        {
            let updateExpectation = XCTestExpectation(description: "Expectation")
            updateExpectations.append(updateExpectation)
            
            updateCallbacks.insert({
                completion($0)
                updateExpectation.fulfill()
            }, at: 0)
        }
        
        return updateExpectations
    }
}

class MMTMockCitiesStore: MMTCitiesStore
{
    var allCities = [MMTCityProt]()
    var searchResult = [MMTCityProt]()
    var currentCity: MMTCityProt?
    var savedCity: MMTCityProt?
    var error: MMTError?
    
    func all(_ completion: @escaping ([MMTCityProt]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            completion(self.allCities)
        }
    }
    
    func city(for location: CLLocation, completion: @escaping (MMTCityProt?, MMTError?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            completion(self.currentCity, self.error)
        }
    }
    
    func cities(maching criteria: String, completion: @escaping ([MMTCityProt]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            completion(self.searchResult)
        }
    }
    
    func save(city: MMTCityProt) {
        savedCity = city
    }
}

class MMTMockForecasterStore: MMTForecasterCommentDataStore
{
    var comment: NSAttributedString?
    var error: MMTError?
    
    func forecasterComment(completion: @escaping (NSAttributedString?, MMTError?) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.comment, self.error)
        }
    }
}
