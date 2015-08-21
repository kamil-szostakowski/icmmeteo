//
//  MMTUmMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public class MMTUmModelStore: MMTGridClimateModelStore
{
    // MARK: Properties
    
    private let waitingTime: NSTimeInterval = 18000
    private var startDate: NSDate!
    
    public override var meteorogramTitle: String {
        return "Model UM"
    }
    
    public override var forecastLength: Int {
        return 60
    }
    
    public override var forecastStartDate: NSDate {
        return self.startDate
    }
    
    // MARK: Initializers
    
    public init(date: NSDate)
    {
        super.init()
        startDate = NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    public override func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion)
    {
        let searchUrl = NSURL.mmt_modelUmSearchUrl(location, tZero: forecastStartDate)
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL.mmt_modelUmDownloadBaseUrl(), completion: completion)
        
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