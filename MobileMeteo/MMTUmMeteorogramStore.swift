//
//  MMTUmMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTUmMeteorogramStore: MMTMeteorogramStore
{
    private let waitingTime: NSTimeInterval = 18000
    
    public override var meteorogramTitle: String {
        return "Model UM"
    }
    
    public override var forecastLength: Int {
        return 60
    }
    
    public override func forecastStartDateForDate(date: NSDate) -> NSDate
    {        
        return NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    public override func getMeteorogramWithQuery(query: MMTMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        let searchUrl = NSURL.mmt_modelUmSearchUrl(query.location, tZero: forecastStartDateForDate(query.date))
        let delegate = MMTMeteorogramFetchDelegate(url: NSURL.mmt_modelUmDownloadBaseUrl(), completion: completion)
        
        NSURLConnection(request: NSURLRequest(URL: searchUrl), delegate: delegate)?.start()
    }
    
    // MARK: Helper methods    
    
    private func tZeroComponentsForDate(date: NSDate) -> NSDateComponents
    {
        let dateWithOffset = date.dateByAddingTimeInterval(-waitingTime)
        let units: NSCalendarUnit = (.CalendarUnitYear)|(.CalendarUnitMonth)|(.CalendarUnitDay)|(.CalendarUnitHour)
        
        let
        components = NSCalendar.utcCalendar.components(units, fromDate: dateWithOffset)
        components.hour = Int(components.hour/6)*6

        return components
    }
}