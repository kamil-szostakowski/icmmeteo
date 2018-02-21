//
//  NSURLSession.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 14.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTMeteorogramUrlSession: NSObject, URLSessionTaskDelegate
{
    // MARK: Properties    
    private var urlSession: URLSession!
    private var redirectionBaseUrl: URL?
    
    #if DEBUG
    static var simulateOfflineMode = false
    static var simulatedError: Error? {
        return simulateOfflineMode ? NSError(domain: "MMTSimulatedError", code: 0, userInfo: nil) : nil
    }
    #endif
    
    // MARK: Initializers
    init(redirectionBaseUrl url: URL?, timeout: TimeInterval)
    {
        super.init()

        let
        config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout

        urlSession = URLSession(configuration: config, delegate:self, delegateQueue:nil)
        redirectionBaseUrl = url
    }

    convenience init(redirectionBaseUrl url: URL?)
    {
        self.init(redirectionBaseUrl: url, timeout: 30)
    }
    
    // MARK: Interface methods
    func fetchImageFromUrl(_ url: URL, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        runTaskWithUrl(url) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in

            guard error == nil else {
                completion(nil, .meteorogramFetchFailure)
                return
            }

            guard let image = UIImage(data) else {
                completion(nil, .meteorogramFetchFailure)
                return
            }

            completion(image, nil)
        }
    }
    
    func fetchMeteorogramImageForUrl(_ searchUrl: URL, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        runTaskWithUrl(searchUrl) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in

            guard error == nil else {
                completion(nil, .meteorogramFetchFailure)
                return
            }

            guard searchUrl.absoluteString != response?.url?.absoluteString else {
                completion(nil, .meteorogramFetchFailure)
                return
            }

            guard let image = UIImage(data) else {
                completion(nil, .meteorogramFetchFailure)
                return
            }
            
            completion(image, nil)
        }
    }
    
    func fetchHTMLContent(from url: URL, encoding: String.Encoding, completion: @escaping MMTFetchHTMLCompletion)
    {
        runTaskWithUrl(url) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let htmlString = self.htmlStringFromResponseData(data, encoding: encoding) {
                completion(htmlString, nil)
            } else {
                completion(nil, .htmlFetchFailure)
            }
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
    
    private func meteorogramDownloadFromRedirectionUrl(_ redirectionUrl: URL) -> URL?
    {
        let urlComponents = redirectionUrl.absoluteString.components(separatedBy: "?")

        guard urlComponents.count == 2 else {
            return nil
        }
        
        return URL(string: "?\(urlComponents.last!)", relativeTo: redirectionBaseUrl)
    }
    
    // MARK: Helper methods
    func runTaskWithUrl(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
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
    
    private func htmlStringFromResponseData(_ data: Data?, encoding: String.Encoding) -> String?
    {
        guard let htmlData = data else { return nil }
        guard let htmlString = String(data: htmlData, encoding: encoding) else { return nil }
        
        return htmlString
    }
}
