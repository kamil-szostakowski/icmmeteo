//
//  MMTCoampsMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics

class MMTCoampsModelStore: NSObject, MMTGridClimateModelStore
{
    // MARK: Properties
    
    private let waitingTime: NSTimeInterval = 21600
    private var urlSession: MMTMeteorogramUrlSession!
    private var startDate: NSDate!    
    
    var forecastLength: Int {
        return 84
    }
    
    var gridNodeSize: Int {
        return 13
    }
    
    var forecastStartDate: NSDate {
        return startDate
    }
    
    var meteorogramSize: CGSize {
        return CGSize(width: 660, height: 570)
    }
    
    var legendSize: CGSize {
        return CGSize(width: 280, height: 570)
    }
    
    // MARK: Initializers
    
    init(date: NSDate)
    {
        super.init()
        
        urlSession = MMTMeteorogramUrlSession(redirectionBaseUrl:  NSURL.mmt_modelCoampsDownloadBaseUrl())
        startDate = NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion)
    {
        let searchUrl = NSURL.mmt_modelCoampsSearchUrl(location, tZero: forecastStartDate)
        urlSession.fetchMeteorogramImageForUrl(searchUrl, completion: completion)
    }
    
    func getMeteorogramLegend(completion: MMTFetchMeteorogramCompletion)
    {        
        urlSession.fetchImageFromUrl(NSURL.mmt_modelCoampsLegendUrl(), completion: completion)
    }
    
    // MARK: Helper methods
    
    private func tZeroComponentsForDate(date: NSDate) -> NSDateComponents
    {
        let dateWithOffset = date.dateByAddingTimeInterval(-waitingTime)
        let units: NSCalendarUnit = [.Year, .Month, .Day, .Hour]

        let
        components = NSCalendar.utcCalendar.components(units, fromDate: dateWithOffset)
        components.hour = components.hour < 12 ? 0 : 12
        
        return components
    }
}
