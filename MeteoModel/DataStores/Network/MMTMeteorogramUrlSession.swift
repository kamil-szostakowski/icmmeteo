//
//  NSURLSession.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 14.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

public class MMTMeteorogramUrlSession: NSObject, URLSessionTaskDelegate
{
    // MARK: Properties    
    private var urlSession: URLSession!
    private var redirectionBaseUrl: URL?
    
    #if DEBUG
    public static var simulateOfflineMode = false
    public static var simulatedError: Error? {
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
    func image(from url: URL, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        runTask(with: url) {
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
    
    func meteorogramImage(from searchUrl: URL, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        runTask(with: searchUrl) {
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
    
    func html(from url: URL, encoding: String.Encoding, completion: @escaping MMTFetchHTMLCompletion)
    {
        runTask(with: url) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard let htmlString = self.html(response: data, encoding: encoding), error == nil else {
                completion(nil, .htmlFetchFailure)
                return
            }
            
            completion(htmlString, nil)
        }
    }
    
    // MARK: NSURLSessionTaskDelegate delegate methods
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void)
    {
        var req: URLRequest?
        
        defer { completionHandler(req) }
        guard let redirectionUrl = request.url else { task.cancel(); return }
        guard let destinationUrl = meteorogramDownloadUrl(from: redirectionUrl) else { task.cancel(); return }
    
        req = URLRequest(url: destinationUrl)
    }
    
    private func meteorogramDownloadUrl(from redirectionUrl: URL) -> URL?
    {
        let urlComponents = redirectionUrl.absoluteString.components(separatedBy: "?")

        guard urlComponents.count == 2 else {
            return nil
        }
        
        return URL(string: "?\(urlComponents.last!)", relativeTo: redirectionBaseUrl)
    }
    
    // MARK: Helper methods
    func runTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let task = urlSession.dataTask(with: url) { (data, response, err) in            
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
    
    private func html(response data: Data?, encoding: String.Encoding) -> String?
    {
        guard let htmlData = data else { return nil }
        guard let htmlString = String(data: htmlData, encoding: encoding) else { return nil }
        
        return htmlString
    }
}
