//
//  MMTWamMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreGraphics

enum MMTWamCategory: String
{
    case TideHeight
    case AvgTidePeriod
    case SpectrumPeakPeriod
}

typealias MMTWamModelMeteorogramQuery = (category: MMTWamCategory, moment: Date)
typealias MMTWamMoment = (date: Date, selected: Bool)

class MMTWamModelStore: NSObject
{
    // MARK: Properties
    
    private let momentLength = 3
    private let waitingTime = TimeInterval(hours: 7)
    private var urlSession: MMTMeteorogramUrlSession!
    private var startDate: Date!

    var forecastLength: Int {
        return 84
    }
    
    var forecastStartDate: Date {
        return startDate
    }
    
    // MARK: Initializers
    
    init(date: Date)
    {
        super.init()
        
        urlSession = MMTMeteorogramUrlSession(redirectionBaseUrl: nil)
        startDate = Calendar.utcCalendar.date(from: tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    func getHoursFromForecastStartDate(forDate endDate: Date) -> Int
    {
        return Int(endDate.timeIntervalSince(startDate)/3600)
    }
    
    func getMeteorogramMomentThumbnailWithQuery(_ query: MMTWamModelMeteorogramQuery, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        var downloadUrl: URL!
        let tZeroPlus = getHoursFromForecastStartDate(forDate: query.moment)
        
        switch query.category
        {
            case .TideHeight: downloadUrl = URL.mmt_modelWamTideHeightThumbnailUrl(startDate, plus: tZeroPlus)
            case .AvgTidePeriod: downloadUrl = URL.mmt_modelWamAvgTidePeriodThumbnailUrl(startDate, plus: tZeroPlus)
            case .SpectrumPeakPeriod: downloadUrl = URL.mmt_modelWamSpectrumPeakPeriodThumbnailUrl(startDate, plus: tZeroPlus)
        }
        
        urlSession.fetchImageFromUrl(downloadUrl, completion: completion)
    }
    
    func getMeteorogramMomentWithQuery(_ query: MMTWamModelMeteorogramQuery, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        var downloadUrl: URL!
        let tZeroPlus = getHoursFromForecastStartDate(forDate: query.moment)
        
        switch query.category
        {
            case .TideHeight: downloadUrl = URL.mmt_modelWamTideHeightDownloadUrl(startDate, plus: tZeroPlus)
            case .AvgTidePeriod: downloadUrl = URL.mmt_modelWamAvgTidePeriodDownloadUrl(startDate, plus: tZeroPlus)
            case .SpectrumPeakPeriod: downloadUrl = URL.mmt_modelWamSpectrumPeakPeriodDownloadUrl(startDate, plus: tZeroPlus)
        }

        urlSession.fetchImageFromUrl(downloadUrl, completion: completion)
    }
    
    func getForecastStartDate(_ completion: @escaping MMTFetchForecastStartDateCompletion)
    {
        urlSession.fetchForecastStartDateFromUrl(URL.mmt_modelWamForecastStartUrl()) {
            (date: Date?, error: MMTError?) in
            
            self.startDate = date ?? Calendar.utcCalendar.date(from: self.tZeroComponentsForDate(Date()))!
            completion(date, error)
        }
    }
    
    func getForecastMoments() -> [MMTWamMoment]
    {
        let momentsCount = forecastLength/momentLength
        var forecastMoments = [MMTWamMoment]()
        
        for index in 1...momentsCount
        {
            let momentOffset = TimeInterval(hours: index*momentLength)
            let moment = startDate.addingTimeInterval(momentOffset)
            
            forecastMoments.append((date: moment, selected: false))
        }
        
        return forecastMoments
    }
    
    // TODO: Write test for this methods
    
    func tZeroComponentsForDate(_ date: Date) -> DateComponents
    {
        let dateWithOffset = date.addingTimeInterval(-waitingTime)
        
        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = components.hour! < 12 ? 0 : 12
        
        return components
    }
}
