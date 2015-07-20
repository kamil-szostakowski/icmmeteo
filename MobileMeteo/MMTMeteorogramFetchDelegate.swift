//
//  MMTMeteorogramFetchDelegate.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 07.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public typealias MMTFetchMeteorogramCompletion = (data: NSData?, error: NSError?) -> Void

public class MMTMeteorogramFetchDelegate: NSObject, NSURLConnectionDataDelegate
{
    let completion: MMTFetchMeteorogramCompletion
    let query: MMTMeteorogramQuery!
    var responseData: NSData?
    
    // MARK: initializers
    
    public init(query: MMTMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        self.completion = completion;
        self.query = query
        
        super.init()
    }
    
    // MARK: Delegate methods
    
    public func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?)
        -> NSURLRequest?
    {
        if let redirectResponse = (response as? NSHTTPURLResponse)
        {
            let locationUri = redirectResponse.allHeaderFields["Location"] as? String
            let queryString = locationUri?.componentsSeparatedByString("?").last
            let redirectUrl = NSURL(string: "?\(queryString!)", relativeToURL: NSURL.mmt_meteorogramDownloadBaseUrl(query.type))
            
            if let url = redirectUrl {
                return NSURLRequest(URL: url)
            }
        }
        
        return request;
    }
    
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
        completion(data: responseData, error: nil)
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError)
    {
        responseData = nil
        completion(data: nil, error: error)
    }
}