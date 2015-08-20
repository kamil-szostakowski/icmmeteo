//
//  MMTWamMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public class MMTWamModelStore: MMTClimateModelStore
{
    public override var meteorogramTitle: String {
        return "Model WAM"
    }

    public override var forecastLength: Int {
        return 84
    }

    public override func forecastStartDateForDate(date: NSDate) -> NSDate
    {
        let units: NSCalendarUnit = (.CalendarUnitYear)|(.CalendarUnitMonth)|(.CalendarUnitDay)|(.CalendarUnitHour)
        
        let
        components = NSCalendar.utcCalendar.components(units, fromDate: date)
        components.hour = 0
        components.minute = 0
        
        return NSCalendar.utcCalendar.dateFromComponents(components)!
    }
    
    public func getMeteorogramMomentThumbnailWithQuery(query: MMTWamModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        var downloadUrl: NSURL!
        
        switch query.category
        {
            case .TideHeight: downloadUrl = NSURL.mmt_modelWamTideHeightThumbnailUrl(query.tZero, plus: query.tZeroPlus)
            case .AvgTidePeriod: downloadUrl = NSURL.mmt_modelWamAvgTidePeriodThumbnailUrl(query.tZero, plus: query.tZeroPlus)
            case .SpectrumPeakPeriod: downloadUrl = NSURL.mmt_modelWamSpectrumPeakPeriodThumbnailUrl(query.tZero, plus: query.tZeroPlus)
        }

        NSURLConnection(request: NSURLRequest(URL: downloadUrl), delegate: MMTMeteorogramFetchDelegate(completion: completion))?.start()
    }
    
    public func getMeteorogramMomentWithQuery(query: MMTWamModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        var downloadUrl: NSURL!
        
        switch query.category
        {
            case .TideHeight: downloadUrl = NSURL.mmt_modelWamTideHeightDownloadUrl(query.tZero, plus: query.tZeroPlus)
            case .AvgTidePeriod: downloadUrl = NSURL.mmt_modelWamAvgTidePeriodDownloadUrl(query.tZero, plus: query.tZeroPlus)
            case .SpectrumPeakPeriod: downloadUrl = NSURL.mmt_modelWamSpectrumPeakPeriodDownloadUrl(query.tZero, plus: query.tZeroPlus)
        }

        NSURLConnection(request: NSURLRequest(URL: downloadUrl), delegate: MMTMeteorogramFetchDelegate(completion: completion))?.start()
    }
}