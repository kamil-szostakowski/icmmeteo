//
//  MMTStubs.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 02.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import XCTest
import Contacts
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
    var result: MMTResult<Date>!
    
    func startDate(_ completion: @escaping (MMTResult<Date>) -> Void) {
        DispatchQueue.main.async {
            completion(self.result)
        }
    }
}

class MMTMockMeteorogramImageStore : MMTMeteorogramImageStore
{
    var meteorogramResult: MMTResult<UIImage>!
    var mapResult: [MMTResult<UIImage>]!
    var legendResult: MMTResult<UIImage>!
    
    var climateModel: MMTClimateModel {
        return MMTUmClimateModel()
    }
    
    func getMeteorogram(for city: MMTCityProt, startDate: Date, completion: @escaping (MMTResult<UIImage>) -> Void) {
        DispatchQueue.main.async {
            completion(self.meteorogramResult)
        }
    }
    
    func getLegend(_ completion: @escaping (MMTResult<UIImage>) -> Void) {
        DispatchQueue.main.async {
            completion(self.legendResult)
        }
    }
    
    func getMeteorogram(for map: MMTDetailedMap, moment: Date, startDate: Date, completion: @escaping (MMTResult<UIImage>) -> Void) {
        DispatchQueue.main.async {
            let result = self.mapResult!.popLast()!
            completion(result)
        }
    }
}

class MMTMockMeteorogramStore: MMTMeteorogramDataStore
{
    var climateModel: MMTClimateModel = MMTUmClimateModel()
    var mapMeteorogram: MMTResult<MMTMapMeteorogram>!
    var meteorogram: MMTResult<MMTMeteorogram>!
    
    func meteorogram(for city: MMTCityProt, completion: @escaping (MMTResult<MMTMeteorogram>) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.meteorogram)
        }
    }
    
    func meteorogram(for map: MMTDetailedMap, completion: @escaping (MMTResult<MMTMapMeteorogram>) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.mapMeteorogram)
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
    var currentCity: MMTResult<MMTCityProt>!
    var savedCity: MMTCityProt?
    
    func all(_ completion:([MMTCityProt]) -> Void) {
        completion(self.allCities)
    }
    
    func city(for location: CLLocation, completion: @escaping (MMTResult<MMTCityProt>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            completion(self.currentCity)
        }
    }
    
    func cities(matching criteria: String, completion: @escaping ([MMTCityProt]) -> Void) {
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
    var comment: MMTResult<NSAttributedString>!
    
    func forecasterComment(completion: @escaping (MMTResult<NSAttributedString>) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.comment)
        }
    }
}

class MMTMockAnalytics: MMTAnalytics
{
    var screen: String!
    var action: MMTAnalyticsAction!
    var category: MMTAnalyticsCategory!
    
    func sendScreenEntryReport(_ screen: String)
    {
        if screen != self.screen {
            XCTFail("Not implemented")
        }
    }
    
    func sendUserActionReport(_ category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel: String)
    {
        if category != self.category || action != self.action {
            XCTFail("Not implemented")
        }
    }
    
    func sendUserActionReport(_ action: MMTAnalyticsReport)
    {
        sendUserActionReport(action.category, action: action.action, actionLabel: action.actionLabel)
    }
}

class MMTMockForecastService: MMTForecastService
{
    var currentMeteorogram: MMTMeteorogram?
    var status: MMTUpdateResult!
    
    func update(for location: CLLocation?, completion: @escaping (MMTUpdateResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            completion(self.status)
        }
    }
}

class MMTMockLocationService: MMTLocationService
{
    var currentLocation: CLLocation?
    
    var authorizationStatus: MMTLocationAuthStatus = .unauthorized
}

class MMTMockGeocoder: MMTGeocoder
{
    var result: MMTResult<[MMTPlacemark]>!
    
    // MARK: Mocked methods
    func geocode(location: CLLocation, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.result)
        }
    }
    
    func geocode(address: CNPostalAddress, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.result)
        }
    }
    
    func cancelGeocode()
    {
    }
}

class MMTMockCityGeocoder: MMTCityGeocoder
{
    var cityForLocation: MMTResult<MMTCityProt>!
    var citiesMatchingCriteria: [MMTCityProt]!
    
    func city(for location: CLLocation, completion: @escaping (MMTResult<MMTCityProt>) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.cityForLocation)
        }
    }
    
    func cities(matching criteria: String, completion: @escaping ([MMTCityProt]) -> Void)
    {
        DispatchQueue.global(qos: .background).async {
            completion(self.citiesMatchingCriteria)
        }
    }
    
    
}
