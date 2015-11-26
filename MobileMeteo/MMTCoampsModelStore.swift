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
    
    private let waitingTime: NSTimeInterval = 18000
    private var startDate: NSDate!
    
    var meteorogramId: MMTClimateModel {
        return .COAMPS
    }
    
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
        startDate = NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion)
    {
        let searchUrl = NSURL.mmt_modelCoampsSearchUrl(location, tZero: forecastStartDate)
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL.mmt_modelCoampsDownloadBaseUrl(), completion: completion)
        
        NSURLConnection(request: NSURLRequest(URL: searchUrl), delegate: delegate)?.start()
    }
    
    func getMeteorogramLegend(completion: MMTFetchMeteorogramCompletion)
    {
        let legendUrl = NSURL.mmt_modelCoampsLegendUrl()
        NSURLConnection(request: NSURLRequest(URL: legendUrl), delegate: MMTMeteorogramFetchDelegate(completion: completion))?.start()
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