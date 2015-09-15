//
//  MMTMeteorogramFetchDelegate.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 07.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public class MMTMeteorogramRedirectionFetchDelegate: MMTMeteorogramFetchDelegate
{
    // MARK: Properties    
    
    private let downloadBaseUrl: NSURL!
    private var wasRedirected = false
    
    
    // MARK: initializers
    
    public init(url: NSURL, completion: MMTFetchMeteorogramCompletion)
    {
        downloadBaseUrl = url
        super.init(completion: completion)
    }
    
    // MARK: Delegate methods
    
    public func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?)
        -> NSURLRequest?
    {
        if let redirectResponse = (response as? NSHTTPURLResponse)
        {
            let locationUri = redirectResponse.allHeaderFields["Location"] as? String
            let queryString = locationUri?.componentsSeparatedByString("?").last
            let redirectUrl = NSURL(string: "?\(queryString!)", relativeToURL: downloadBaseUrl)
            
            if let url = redirectUrl
            {
                wasRedirected = true
                return NSURLRequest(URL: url)
            }
        }
        
        return request
    }
    
    public override func connectionDidFinishLoading(connection: NSURLConnection)
    {
        if wasRedirected {
            super.connectionDidFinishLoading(connection)
        }
        
        else {
            super.connection(connection, didFailWithError: NSError(code: .MeteorogramNotFound))
        }
    }
}