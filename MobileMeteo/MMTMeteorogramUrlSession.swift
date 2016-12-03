//
//  NSURLSession.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 14.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTMeteorogramUrlSession: NSObject, URLSessionTaskDelegate
{
    // MARK: Properties
    
    fileprivate var urlSession: URLSession!
    fileprivate var redirectionBaseUrl: URL?
    
    #if DEBUG
    static var simulateOfflineMode = false
    static var simulatedError: Error? {
        return simulateOfflineMode ? NSError(domain: "MMTSimulatedError", code: 0, userInfo: nil) : nil
    }
    #endif
    
    // MARK: Initializers
    
    override init()
    {
        super.init()
        urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate:self, delegateQueue:nil)
    }
    
    convenience init(redirectionBaseUrl url: URL?)
    {
        self.init()
        redirectionBaseUrl = url
    }
    
    // MARK: Interface methods
    
    func fetchImageFromUrl(_ url: URL, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        runTaskWithUrl(url) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            completion(data, error != nil ? .meteorogramFetchFailure : nil)
        }
    }
    
    func fetchMeteorogramImageForUrl(_ searchUrl: URL, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        runTaskWithUrl(searchUrl) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            let redirected =  searchUrl.absoluteString != response?.url?.absoluteString
            
            var
            err: MMTError? = nil
            err = !redirected ? .meteorogramNotFound : err
            err = error != nil ? .meteorogramFetchFailure : err
            
            completion(data, err)
        }
    }
    
    func fetchForecastStartDateFromUrl(_ infoUrl: URL, completion: @escaping MMTFetchForecastStartDateCompletion)
    {
        runTaskWithUrl(infoUrl) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            var forecastStartDate: Date?
            var err: MMTError? = nil
            
            if let htmlString = self.htmlStringFromResponseData(data) {
                forecastStartDate = self.forecastStartDateFromHtmlResponse(htmlString)
            }
            
            err = forecastStartDate != nil ? nil : .forecastStartDateNotFound
            completion(forecastStartDate, err)
        }
    }
    
    // MARK: NSURLSessionTaskDelegate delegate methods
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void)
    {
        var req: URLRequest?
        
        defer { completionHandler(req) }
        guard let requestUrl = request.url else { task.cancel(); return }
        guard let destinationUrl = meteorogramDownloadFromRedirectionUrl(requestUrl) else { task.cancel(); return }
    
        req = URLRequest(url: destinationUrl)
    }
    
    fileprivate func meteorogramDownloadFromRedirectionUrl(_ redirectionUrl: URL) -> URL?
    {        
        guard let queryString = redirectionUrl.absoluteString.components(separatedBy: "?").last else {
            return nil
        }
        
        return URL(string: "?\(queryString)", relativeTo: redirectionBaseUrl)
    }
    
    // MARK: Helper methods
    
    fileprivate func runTaskWithUrl(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let task = urlSession.dataTask(with: url){
            (data: Data?, response: URLResponse?, err: Error?) -> Swift.Void in
            
            var error = err
            
            #if DEBUG
            error = MMTMeteorogramUrlSession.simulatedError ?? error
            #endif
            
            DispatchQueue.main.async(execute: {
                completion(data, response, error)
            })
        }
        
        task.resume()
    }
    
    func htmlStringFromResponseData(_ data: Data?) -> String?
    {
        guard let htmlData = data else { return nil }
        guard let htmlString = String(data: htmlData, encoding: String.Encoding.windowsCP1250) else { return nil }
        
        return htmlString
    }
    
    func forecastStartDateFromHtmlResponse(_ html: String) -> Date?
    {
        let pattern = "[0-9]{4}\\.[0-9]{2}\\.[0-9]{2} [0-9]{2}:[0-9]{2} UTC"
        let range = NSMakeRange(0, html.lengthOfBytes(using: String.Encoding.windowsCP1250))
        
        guard let regexp = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options()) else { return nil }        
        let hits = regexp.matches(in: html, options: NSRegularExpression.MatchingOptions(), range: range)
        
        guard let match = hits.first else { return nil }
        let dateString = (html as NSString).substring(with: match.range)
        
        return DateFormatter.utcFormatter.date(from: dateString)
    }
}
