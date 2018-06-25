//
//  MMTForecastStore.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

public protocol MMTForecastStore
{    
    func startDate(_ completion: @escaping (MMTResult<Date>) -> Void)
}

public struct MMTWebForecastStore : MMTForecastStore
{
    // MARK: Properties
    let urlSession: MMTMeteorogramUrlSession
    let climateModel: MMTClimateModel
    
    // MARK: Initializers
    public init(model: MMTClimateModel, session: MMTMeteorogramUrlSession)
    {
        climateModel = model
        urlSession = session
    }
    
    // MARK: Methods
    public func startDate(_ completion: @escaping (MMTResult<Date>) -> Void)
    {
        urlSession.html(from: try! URL.mmt_forecastStartUrl(for: climateModel.type), encoding: .windowsCP1250) {
            (result: MMTResult<String>) in
            
            guard case let .success(html) = result else {
                completion(.failure(.forecastStartDateNotFound))
                return
            }
            
            guard let date = self.startDate(from: html) else {
                completion(.failure(.forecastStartDateNotFound))
                
                return
            }
            
            completion(.success(date))
        }
    }    
    
    // MARK: Helper methods
    func startDate(from html: String) -> Date?
    {
        let pattern = "[0-9]{4}\\.[0-9]{2}\\.[0-9]{2} [0-9]{2}:[0-9]{2} UTC"
        let range = NSMakeRange(0, html.lengthOfBytes(using: String.Encoding.windowsCP1250))
        
        let regexp = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        let hits = regexp.matches(in: html, options: NSRegularExpression.MatchingOptions(), range: range)
        
        guard let match = hits.first else { return nil }
        let dateString = (html as NSString).substring(with: match.range)
        
        return DateFormatter.utcFormatter.date(from: dateString)
    }
}
