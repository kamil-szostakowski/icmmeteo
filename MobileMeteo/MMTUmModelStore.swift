//
//  MMTUmMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics

class MMTUmModelStore: NSObject, MMTGridClimateModelStore
{
    // MARK: Properties
    
    private let waitingTime = NSTimeInterval(hours: 5)
    private var urlSession: MMTMeteorogramUrlSession!
    private var startDate: NSDate!
    
    var forecastLength: Int {
        return 60
    }
    
    var gridNodeSize: Int {
        return 4
    }
    
    var forecastStartDate: NSDate {
        return startDate
    }
    
    var meteorogramSize: CGSize {
        return CGSize(width: 540, height: 660)
    }
    
    var legendSize: CGSize {
        return CGSize(width: 280, height: 660)
    }
    
    // MARK: Initializers
    
    init(date: NSDate)
    {
        super.init()
        
        urlSession = MMTMeteorogramUrlSession(redirectionBaseUrl: NSURL.mmt_modelUmDownloadBaseUrl())
        startDate = NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion)
    {
        urlSession.fetchMeteorogramImageForUrl(NSURL.mmt_modelUmSearchUrl(location), completion: completion)
    }
    
    func getMeteorogramLegend(completion: MMTFetchMeteorogramCompletion)
    {        
        urlSession.fetchImageFromUrl(NSURL.mmt_modelUmLegendUrl(), completion: completion)
    }
    
    func getForecastStartDate(completion: MMTFetchForecastStartDateCompletion)
    {
        urlSession.fetchForecastStartDateFromUrl(NSURL.mmt_modelUmForecastStartUrl()) {
            (date: NSDate?, error: MMTError?) in            
            
            self.startDate = date ?? NSCalendar.utcCalendar.dateFromComponents(self.tZeroComponentsForDate(NSDate()))!
            completion(date: date, error: error)
        }
    }
    
    // MARK: Helper methods    
    
    private func tZeroComponentsForDate(date: NSDate) -> NSDateComponents
    {
        let dateWithOffset = date.dateByAddingTimeInterval(-waitingTime)
        
        let
        components = NSCalendar.utcCalendar.components([.Year, .Month, .Day, .Hour], fromDate: dateWithOffset)
        components.hour = Int(components.hour/6)*6

        return components
    }    
}
