//
//  MMTMeteorogramFetchDelegate.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public typealias MMTFetchMeteorogramCompletion = (data: NSData?, error: NSError?) -> Void

public class MMTMeteorogramFetchDelegate: NSObject, NSURLConnectionDataDelegate
{
    // MARK: Properties
    
    private let MMTEmptyMeteorogramSize = 71
    
    let completion: MMTFetchMeteorogramCompletion
    var responseData: NSData?
    
    // MARK: Initializers
    
    public init(completion: MMTFetchMeteorogramCompletion)
    {
        self.completion = completion;
        
        super.init()
    }
    
    // MARK: Protocol methods
    
    public func connection(connection: NSURLConnection, didReceiveData data: NSData)
    {
        let responseData = self.responseData != nil ?
            NSMutableData(data: self.responseData!) :
            NSMutableData(data: data)
        
        if self.responseData != nil {
            responseData.appendData(data)
        }
        
        self.responseData = NSData(data: responseData)
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection)
    {
        switch responseData?.length <= MMTEmptyMeteorogramSize
        {
            case true: completion(data: nil, error: errorWithCode(.MeteorogramNotFound))
            case false: completion(data: responseData, error: nil)
            
            default: break
        }
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError)
    {
        responseData = nil
        completion(data: nil, error: errorWithCode(.MeteorogramFetchFailure))
    }
    
    // MARK: Helper methods
    
    private func errorWithCode(code: MMTError) -> NSError
    {
        return NSError(domain: MMTErrorDomain, code: code.rawValue, userInfo: nil)
    }
}