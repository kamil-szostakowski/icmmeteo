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
    case TideHeight = "Wysokość fali znacznej i średni kierunek fali"
    case AvgTidePeriod = "Średni okres fali"
    case SpectrumPeakPeriod = "Okres piku widma"    
}

typealias MMTWamModelMeteorogramQuery = (category: MMTWamCategory, moment: NSDate)
typealias MMTWamMoment = (date: NSDate, selected: Bool)

class MMTWamModelStore: NSObject, MMTClimateModelStore
{
    // MARK: Properties
    
    private let waitingTime = NSTimeInterval(hours: 7)
    private var urlSession: MMTMeteorogramUrlSession!
    private let momentLength = 3
    private var startDate: NSDate!
    
    var meteorogramSize: CGSize {
        return CGSize(width: 720, height: 702)
    }

    var forecastLength: Int {
        return 84
    }
    
    var forecastStartDate: NSDate {
        return startDate
    }
    
    // MARK: Initializers
    
    init(date: NSDate)
    {
        super.init()
        
        urlSession = MMTMeteorogramUrlSession()
        startDate = NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    func getHoursFromForecastStartDate(forDate endDate: NSDate) -> Int
    {
        return Int(endDate.timeIntervalSinceDate(startDate)/3600)
    }
    
    func getMeteorogramMomentThumbnailWithQuery(query: MMTWamModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        var downloadUrl: NSURL!
        let tZeroPlus = getHoursFromForecastStartDate(forDate: query.moment)
        
        switch query.category
        {
            case .TideHeight: downloadUrl = NSURL.mmt_modelWamTideHeightThumbnailUrl(startDate, plus: tZeroPlus)
            case .AvgTidePeriod: downloadUrl = NSURL.mmt_modelWamAvgTidePeriodThumbnailUrl(startDate, plus: tZeroPlus)
            case .SpectrumPeakPeriod: downloadUrl = NSURL.mmt_modelWamSpectrumPeakPeriodThumbnailUrl(startDate, plus: tZeroPlus)
        }
        
        urlSession.fetchImageFromUrl(downloadUrl, completion: completion)
    }
    
    func getMeteorogramMomentWithQuery(query: MMTWamModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        var downloadUrl: NSURL!
        let tZeroPlus = getHoursFromForecastStartDate(forDate: query.moment)
        
        switch query.category
        {
            case .TideHeight: downloadUrl = NSURL.mmt_modelWamTideHeightDownloadUrl(startDate, plus: tZeroPlus)
            case .AvgTidePeriod: downloadUrl = NSURL.mmt_modelWamAvgTidePeriodDownloadUrl(startDate, plus: tZeroPlus)
            case .SpectrumPeakPeriod: downloadUrl = NSURL.mmt_modelWamSpectrumPeakPeriodDownloadUrl(startDate, plus: tZeroPlus)
        }

        urlSession.fetchImageFromUrl(downloadUrl, completion: completion)
    }
    
    func getForecastStartDate(completion: MMTFetchForecastStartDateCompletion)
    {
        urlSession.fetchForecastStartDateFromUrl(NSURL.mmt_modelWamForecastStartUrl()) {
            (date: NSDate?, error: MMTError?) in
            
            self.startDate = date ?? NSCalendar.utcCalendar.dateFromComponents(self.tZeroComponentsForDate(NSDate()))!
            completion(date: date, error: error)
        }
    }
    
    func getForecastMoments() -> [MMTWamMoment]
    {
        let momentsCount = forecastLength/momentLength
        var forecastMoments = [MMTWamMoment]()
        
        for index in 1...momentsCount
        {
            let momentOffset = NSTimeInterval(hours: index*momentLength)
            let moment = startDate.dateByAddingTimeInterval(momentOffset)
            
            forecastMoments.append((date: moment, selected: false))
        }
        
        return forecastMoments
    }
    
    // MARK: Helper methods
    
    private func tZeroComponentsForDate(date: NSDate) -> NSDateComponents
    {
        let dateWithOffset = date.dateByAddingTimeInterval(-waitingTime)
        
        let
        components = NSCalendar.utcCalendar.components([.Year, .Month, .Day, .Hour], fromDate: dateWithOffset)
        components.hour = components.hour < 12 ? 0 : 12
        
        return components
    }
}