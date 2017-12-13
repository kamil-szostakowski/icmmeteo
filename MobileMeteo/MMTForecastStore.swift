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
typealias MMTFetchMeteorogramsCompletion = (_ image: UIImage?, _ date: Date?, _ error: MMTError?, _ finish: Bool) -> Void

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
        urlSession.fetchForecastStartDateFromUrl(try! URL.mmt_forecastStartUrl(for: climateModel.type)) {
            (date: Date?, error: MMTError?) in
            
            self.forecastStartDate = date ?? self.climateModel.startDate(for: Date())
            completion(date, error)
        }
    }
    
    func getHoursFromForecastStartDate(forDate endDate: Date) -> Int
    {
        return Int(endDate.timeIntervalSince(forecastStartDate)/3600)
    }
}
