//
//  NSURLSession.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 14.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTMeteorogramUrlSession: NSObject, NSURLSessionTaskDelegate
{
    // MARK: Properties
    
    private var urlSession: NSURLSession!
    private var climateModel: MMTClimateModel
    
    // MARK: Initializers
    
    init(model: MMTClimateModel)
    {
        climateModel = model
        
        super.init()
        
        urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate:self, delegateQueue:nil)
    }
    
    // MARK: Interface methods
    
    func fetchImageFromUrl(url: NSURL, completion: MMTFetchMeteorogramCompletion)
    {
        let task = urlSession.dataTaskWithURL(url) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(data: data, error: error != nil ? .MeteorogramFetchFailure : nil)
            })
        }
        
        task.resume()
    }
    
    func fetchMeteorogramImageForUrl(searchUrl: NSURL, completion: MMTFetchMeteorogramCompletion)
    {
        let task = urlSession.dataTaskWithURL(searchUrl) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            let redirected =  searchUrl.absoluteString != response?.URL?.absoluteString
            
            var
            err: MMTError?
            err = !redirected ? .MeteorogramNotFound : nil
            err = error != nil ? .MeteorogramFetchFailure : err
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(data: data, error: err)
            })
        }
        
        task.resume()
    }
    
    // MARK: NSURLSessionTaskDelegate delegate methods
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void)
    {
        guard let destinationUrl = meteorogramDownloadUrlForRedirection(request.URL!) else {
            task.cancel()
            completionHandler(nil)
            return
        }
    
        completionHandler(NSURLRequest(URL: destinationUrl))
    }
    
    private func meteorogramDownloadUrlForRedirection(redirectionUrl: NSURL) -> NSURL?
    {
        switch climateModel
        {
            case .UM: return NSURL.mmt_modelUmMeteorogramUrl(redirectionUrl)
            case .COAMPS: return NSURL.mmt_modelCoampsMeteorogramUrl(redirectionUrl)
            default: return nil
        }
    }
}
