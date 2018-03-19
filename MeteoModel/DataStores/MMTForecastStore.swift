//
//  MMTForecastStore.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

public struct MMTForecastStore
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

    public init(model: MMTClimateModel)
    {
        let url = try? URL.mmt_meteorogramDownloadBaseUrl(for: model.type)
        let session = MMTMeteorogramUrlSession(redirectionBaseUrl: url, timeout: 60)

        self.init(model: model, session: session)
    }
    
    // MARK: Methods
    public func startDate(_ completion: @escaping MMTFetchForecastStartDateCompletion)
    {
        urlSession.fetchHTMLContent(from: try! URL.mmt_forecastStartUrl(for: climateModel.type), encoding: .windowsCP1250) {
            (html: String?, error: MMTError?) in
            
            let reportError = {
                completion(nil, .forecastStartDateNotFound)
            }
            
            guard let htmlString = html, error == nil else {
                reportError()
                return
            }
            
            guard let date = self.startDate(from: htmlString) else {
                reportError()
                return
            }
            
            completion(date, nil)
        }
    }    
    
    // MARK: Helper methods
    private func startDate(from html: String) -> Date?
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
