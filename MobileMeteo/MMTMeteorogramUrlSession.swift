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
    private var redirectionBaseUrl: NSURL?
    
    #if DEBUG
    static var simulateOfflineMode = false
    static var simulatedError: NSError? {
        return simulateOfflineMode ? NSError(domain: "MMTSimulatedError", code: 0, userInfo: nil) : nil
    }
    #endif
    
    // MARK: Initializers
    
    override init()
    {
        super.init()
        urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate:self, delegateQueue:nil)
    }
    
    convenience init(redirectionBaseUrl url: NSURL?)
    {
        self.init()
        redirectionBaseUrl = url
    }
    
    // MARK: Interface methods
    
    func fetchImageFromUrl(url: NSURL, completion: MMTFetchMeteorogramCompletion)
    {
        runTaskWithUrl(url) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            completion(data: data, error: error != nil ? .MeteorogramFetchFailure : nil)
        }
    }
    
    func fetchMeteorogramImageForUrl(searchUrl: NSURL, completion: MMTFetchMeteorogramCompletion)
    {
        runTaskWithUrl(searchUrl) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            let redirected =  searchUrl.absoluteString != response?.URL?.absoluteString
            
            var
            err: MMTError?
            err = !redirected ? .MeteorogramNotFound : nil
            err = error != nil ? .MeteorogramFetchFailure : err
            
            completion(data: data, error: err)
        }
    }
    
    func fetchForecastStartDateFromUrl(infoUrl: NSURL, completion: MMTFetchForecastStartDateCompletion)
    {
        runTaskWithUrl(infoUrl) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            var forecastStartDate: NSDate?
            var err: MMTError?
            
            if let htmlString = self.htmlStringFromResponseData(data) {
                forecastStartDate = self.forecastStartDateFromHtmlResponse(htmlString)
            }
            
            err = forecastStartDate != nil ? nil : .ForecastStartDateNotFound
            completion(date: forecastStartDate, error: err)
        }
    }
    
    // MARK: NSURLSessionTaskDelegate delegate methods
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void)
    {
        guard let destinationUrl = meteorogramDownloadFromRedirectionUrl(request.URL!) else {
            task.cancel()
            completionHandler(nil)
            return
        }
    
        completionHandler(NSURLRequest(URL: destinationUrl))
    }
    
    private func meteorogramDownloadFromRedirectionUrl(redirectionUrl: NSURL) -> NSURL?
    {
        guard let baseUrl = redirectionBaseUrl else {
            return nil
        }
        
        guard let queryString = redirectionUrl.absoluteString.componentsSeparatedByString("?").last else {
            return nil
        }
        
        return NSURL(string: "?\(queryString)", relativeToURL: baseUrl)
    }
    
    // MARK: Helper methods
    
    private func runTaskWithUrl(url: NSURL, completion: (NSData?, NSURLResponse?, NSError?) -> Void)
    {
        let task = urlSession.dataTaskWithURL(url) {
            (data: NSData?, response: NSURLResponse?, var error: NSError?) -> Void in
            
            #if DEBUG
            error = MMTMeteorogramUrlSession.simulatedError ?? error
            #endif
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(data, response, error)
            })
        }
        
        task.resume()
    }
    
    func htmlStringFromResponseData(data: NSData?) -> String?
    {
        guard let htmlData = data else { return nil }
        guard let htmlString = String(data: htmlData, encoding: NSWindowsCP1250StringEncoding) else { return nil }
        
        return htmlString
    }
    
    func forecastStartDateFromHtmlResponse(html: String) -> NSDate?
    {
        let pattern = "[0-9]{4}\\.[0-9]{2}\\.[0-9]{2} [0-9]{2}:[0-9]{2} UTC"
        let range = NSMakeRange(0, html.lengthOfBytesUsingEncoding(NSWindowsCP1250StringEncoding))
        
        guard let regexp = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions()) else { return nil }        
        let hits = regexp.matchesInString(html, options: NSMatchingOptions(), range: range)
        
        guard let match = hits.first else { return nil }
        let dateString = (html as NSString).substringWithRange(match.range)
        
        return NSDateFormatter.utcFormatter.dateFromString(dateString)
    }
}
