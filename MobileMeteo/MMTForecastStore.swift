//
//  MMTForecastStore.swift
//  MobileMeteo
//
//  Created by Kamil on 23.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

typealias MMTFetchMeteorogramCompletion = (_ image: UIImage?, _ error: MMTError?) -> Void
typealias MMTFetchForecastStartDateCompletion = (_ date: Date?, _ error: MMTError?) -> Void
typealias MMTFetchHTMLCompletion = (_ html: String?, _ error: MMTError?) -> Void
typealias MMTFetchMeteorogramsCompletion = (_ image: UIImage?, _ date: Date?, _ error: MMTError?, _ finish: Bool) -> Void
typealias MMTFetchCommentCompletion = (_ comment: NSAttributedString?, _ error: MMTError?) -> Void

class MMTForecastStore
{
    // MARK: Properties
    private(set) var urlSession: MMTMeteorogramUrlSession
    private(set) var forecastStartDate: Date
    private(set) var climateModel: MMTClimateModel
    
    // MARK: Initializers
    init(model: MMTClimateModel, date: Date, session: MMTMeteorogramUrlSession)
    {
        climateModel = model
        forecastStartDate = date
        urlSession = session
    }

    convenience init(model: MMTClimateModel, date: Date)
    {
        let url = try? URL.mmt_meteorogramDownloadBaseUrl(for: model.type)
        let session = MMTMeteorogramUrlSession(redirectionBaseUrl: url, timeout: 60)

        self.init(model: model, date: date, session: session)
    }
    
    // MARK: Methods
    
    func getForecastStartDate(_ completion: @escaping MMTFetchForecastStartDateCompletion)
    {
        urlSession.fetchHTMLContent(from: try! URL.mmt_forecastStartUrl(for: climateModel.type), encoding: .windowsCP1250) {
            (html: String?, error: MMTError?) in
            
            let reportError = {
                self.forecastStartDate = self.climateModel.startDate(for: Date())
                completion(nil, .forecastStartDateNotFound)
            }
            
            guard let htmlString = html, error == nil else {
                reportError()
                return
            }
            
            guard let date = self.forecastStartDateFromHtmlResponse(htmlString) else {
                reportError()
                return
            }
            
            self.forecastStartDate = date
            completion(date, nil)
        }
    }
    
    func getHoursFromForecastStartDate(forDate endDate: Date) -> Int
    {
        return Int(endDate.timeIntervalSince(forecastStartDate)/3600)
    }
    
    // MARK: Helper methods
    private func forecastStartDateFromHtmlResponse(_ html: String) -> Date?
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
