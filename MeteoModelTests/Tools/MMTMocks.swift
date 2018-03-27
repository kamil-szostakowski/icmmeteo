//
//  MMTStubs.swift
//  MeteoModelTests
//
//  Created by szostakowskik on 02.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
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
