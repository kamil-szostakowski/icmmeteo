//
//  MMTCoampsMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTCoampsModelStore: MMTGridClimateModelStore
{
    private let waitingTime: NSTimeInterval = 18000    
    
    public override var meteorogramTitle: String {
        return "Model COAMPS"
    }
    
    public override var forecastLength: Int {
        return 84
    }
    
    public override func forecastStartDateForDate(date: NSDate) -> NSDate
    {
        return NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    public override func getMeteorogramWithQuery(query: MMTGridModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        let searchUrl = NSURL.mmt_modelCoampsSearchUrl(query.location, tZero: forecastStartDateForDate(query.date))
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL.mmt_modelCoampsDownloadBaseUrl(), completion: completion)
        
        NSURLConnection(request: NSURLRequest(URL: searchUrl), delegate: delegate)?.start()
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