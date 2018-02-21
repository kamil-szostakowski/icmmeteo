//
//  MMTStubs.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 15.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
@testable import MobileMeteo

struct MMTStubLocationService : MMTLocationService
{
    var currentLocation: CLLocation? {
        return nil
    }
}

class MMTUnsupportedShortcut: MMTShortcut
{
    var identifier: String = ""
    
    func execute(using tabbar: MMTTabBarController, completion: MMTCompletion?) { }
}

class StubMigrator : MMTVersionMigrator
{
    private(set) var sequenceNumber: UInt
    private(set) var migrated = false
    
    init(sequenceNumber: UInt)
    {
        self.sequenceNumber = sequenceNumber
        self.migrated = false
    }
    
    func migrate()
    {
        migrated = true
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
    
    override func runTaskWithUrl(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        completion(mockData, mockResponse, mockError)
    }
}

class MMTMockTask: URLSessionTask
{
    override func cancel() {}
}
