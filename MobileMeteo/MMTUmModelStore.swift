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
    
    private let waitingTime: NSTimeInterval = 18000
    private var startDate: NSDate!
    
    var meteorogramId: MMTClimateModel {
        return .UM
    }
    
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
        startDate = NSCalendar.utcCalendar.dateFromComponents(tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion)
    {
        let searchUrl = NSURL.mmt_modelUmSearchUrl(location, tZero: forecastStartDate)
        let delegate = MMTMeteorogramRedirectionFetchDelegate(url: NSURL.mmt_modelUmDownloadBaseUrl(), completion: completion)
        
        NSURLConnection(request: NSURLRequest(URL: searchUrl), delegate: delegate)?.start()
    }
    
    func getMeteorogramLegend(completion: MMTFetchMeteorogramCompletion)
    {
        let legendUrl = NSURL.mmt_modelUmLegendUrl()
        NSURLConnection(request: NSURLRequest(URL: legendUrl), delegate: MMTMeteorogramFetchDelegate(completion: completion))?.start()
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