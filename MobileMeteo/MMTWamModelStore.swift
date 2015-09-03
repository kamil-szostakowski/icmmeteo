//
//  MMTWamMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreGraphics

public enum MMTWamCategory: Int
{
    case TideHeight = 0
    case AvgTidePeriod
    case SpectrumPeakPeriod
    
    var description: String
    {
        let descriptions = [
            "Wysokość fali znacznej i średni kierunek fali",
            "Średni okres fali",
            "Okres piku widma"
        ]
            
        return descriptions[self.rawValue]
    }
}

public typealias MMTWamModelMeteorogramQuery = (category: MMTWamCategory, moment: NSDate)
public typealias MMTWamMoment = (date: NSDate, selected: Bool)

public class MMTWamModelStore: MMTClimateModelStore
{
    // MARK: Properties
    
    private let waitingTime: NSTimeInterval = 25200
    private let momentLength = 3
    private var startDate: NSDate!
    
    public override var meteorogramId: MMTClimateModel {
        return .WAM
    }
    
    public override var meteorogramSize: CGSize {
        return CGSize(width: 720, height: 702)
    }

    public override var forecastLength: Int {
        return 84
    }
    
    public override var forecastStartDate: NSDate {
        return startDate
    }
    
    // MARK: Initializers
    
    public init(date: NSDate)
    {
        super.init()        
        startDate = NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    public func getHoursFromForecastStartDate(forDate endDate: NSDate) -> Int
    {
        return Int(endDate.timeIntervalSinceDate(startDate)/3600)
    }
    
    public func getMeteorogramMomentThumbnailWithQuery(query: MMTWamModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        var downloadUrl: NSURL!
        let tZeroPlus = getHoursFromForecastStartDate(forDate: query.moment)
        
        switch query.category
        {
            case .TideHeight: downloadUrl = NSURL.mmt_modelWamTideHeightThumbnailUrl(startDate, plus: tZeroPlus)
            case .AvgTidePeriod: downloadUrl = NSURL.mmt_modelWamAvgTidePeriodThumbnailUrl(startDate, plus: tZeroPlus)
            case .SpectrumPeakPeriod: downloadUrl = NSURL.mmt_modelWamSpectrumPeakPeriodThumbnailUrl(startDate, plus: tZeroPlus)
        }

        NSURLConnection(request: NSURLRequest(URL: downloadUrl), delegate: MMTMeteorogramFetchDelegate(completion: completion))?.start()
    }
    
    public func getMeteorogramMomentWithQuery(query: MMTWamModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        var downloadUrl: NSURL!
        let tZeroPlus = getHoursFromForecastStartDate(forDate: query.moment)
        
        switch query.category
        {
            case .TideHeight: downloadUrl = NSURL.mmt_modelWamTideHeightDownloadUrl(startDate, plus: tZeroPlus)
            case .AvgTidePeriod: downloadUrl = NSURL.mmt_modelWamAvgTidePeriodDownloadUrl(startDate, plus: tZeroPlus)
            case .SpectrumPeakPeriod: downloadUrl = NSURL.mmt_modelWamSpectrumPeakPeriodDownloadUrl(startDate, plus: tZeroPlus)
        }

        NSURLConnection(request: NSURLRequest(URL: downloadUrl), delegate: MMTMeteorogramFetchDelegate(completion: completion))?.start()
    }
    
    public func getForecastMoments() -> [MMTWamMoment]
    {
        let momentsCount = forecastLength/momentLength
        var forecastMoments = [MMTWamMoment]()
        
        for index in 1...momentsCount
        {
            let momentOffset = NSTimeInterval(index*momentLength*3600)
            let moment = startDate.dateByAddingTimeInterval(momentOffset)
            
            forecastMoments.append((date: moment, selected: false))
        }
        
        return forecastMoments
    }
    
    // MARK: Helper methods
    
    private func tZeroComponentsForDate(date: NSDate) -> NSDateComponents
    {
        let dateWithOffset = date.dateByAddingTimeInterval(-waitingTime)
        let units: NSCalendarUnit = (.CalendarUnitYear)|(.CalendarUnitMonth)|(.CalendarUnitDay)|(.CalendarUnitHour)
        
        let
        components = NSCalendar.utcCalendar.components(units, fromDate: dateWithOffset)
        components.hour = components.hour < 12 ? 0 : 12
        
        return components
    }
}