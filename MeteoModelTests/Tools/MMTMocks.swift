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

class MMTTestDispatcher
{
    private static var dispatchAsync = false
    private static let queue = DispatchQueue(label: "test queue")
    
    public static func dispatch(call: @escaping () -> Void)
    {
        switch dispatchAsync {
            case true: queue.async { call() }
            case false: call()
        }
    }
}

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
    
    func startDate(_ completion: @escaping (MMTResult<Date>) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.result) }
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
    
    func getMeteorogram(for city: MMTCityProt, startDate: Date, completion: @escaping (MMTResult<UIImage>) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.meteorogramResult) }
    }
    
    func getLegend(_ completion: @escaping (MMTResult<UIImage>) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.legendResult) }
    }
    
    func getMeteorogram(for map: MMTDetailedMap, moment: Date, startDate: Date, completion: @escaping (MMTResult<UIImage>) -> Void) {
        MMTTestDispatcher.dispatch {
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
        MMTTestDispatcher.dispatch { completion(self.meteorogram) }
    }
    
    func meteorogram(for map: MMTDetailedMap, completion: @escaping (MMTResult<MMTMapMeteorogram>) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.mapMeteorogram) }
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
    
    func all(_ completion:([MMTCityProt]) -> Void)
    {
        completion(self.allCities)
    }
    
    func city(for location: CLLocation, completion: @escaping (MMTResult<MMTCityProt>) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.currentCity) }
    }
    
    func cities(matching criteria: String, completion: @escaping ([MMTCityProt]) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.searchResult) }
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
        MMTTestDispatcher.dispatch { completion(self.comment) }
    }
}

class MMTMockForecastService: MMTForecastService
{
    var currentMeteorogram: MMTMeteorogram?
    var status: MMTUpdateResult = .failed
    
    func update(for location: MMTCityProt, completion: @escaping (MMTUpdateResult) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.status) }
    }
}

class MMTMockLocationService: MMTLocationService
{
    var location: MMTCityProt?
    var authorizationStatus: MMTLocationAuthStatus = .unauthorized
    var locationPromise = MMTPromise<MMTCityProt>()
    
    func requestLocation() -> MMTPromise<MMTCityProt> {
        return locationPromise
    }
}

class MMTMockGeocoder: MMTGeocoder
{
    var result: MMTResult<[MMTPlacemark]>!
    
    // MARK: Mocked methods
    func geocode(location: CLLocation, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.result) }
    }
    
    func geocode(address: CNPostalAddress, completion: @escaping (MMTResult<[MMTPlacemark]>) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.result) }
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
        MMTTestDispatcher.dispatch { completion(self.cityForLocation) }
    }
    
    func cities(matching criteria: String, completion: @escaping ([MMTCityProt]) -> Void)
    {
        MMTTestDispatcher.dispatch { completion(self.citiesMatchingCriteria) }
    }
}

class MMTMockLocationManager: CLLocationManager
{
    var mockLocation: CLLocation?
    
    override var location: CLLocation? {
        return mockLocation
    }
}

struct MMTMockPlacemark: MMTPlacemark
{
    var name: String?
    var locality: String?
    var ocean: String?
    var location: CLLocation?
    var administrativeArea: String?
}

class MMTMockMeteorogramCache: MMTMeteorogramCache
{
    var meteorogram: MMTMeteorogram?
    var storeCount: Int = 0
    
    @discardableResult
    func store(_ meteorogram: MMTMeteorogram) -> Bool {
        self.meteorogram = meteorogram
        self.storeCount += 1
        return true
    }
    
    func restore() -> MMTMeteorogram? {
        return meteorogram
    }
    
    @discardableResult
    func cleanup() -> Bool {
        self.meteorogram = nil
        return true
    }        
}

class MMTMockPredictionModel: MMTPredictionModel
{
    var prediction: MMTMeteorogram.Prediction!
    
    init(_ prediction: MMTMeteorogram.Prediction?) {
        self.prediction = prediction
    }
    
    func predict(_ image: MMTMeteorogram) throws -> MMTMeteorogram.Prediction {
        return prediction
    }        
}
