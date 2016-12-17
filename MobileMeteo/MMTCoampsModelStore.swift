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

class MMTCoampsModelStore: NSObject, MMTGridClimateModelStore, MMTDetailedMapsStore
{
    // MARK: Properties
    
    fileprivate let waitingTime = TimeInterval(hours: 6)
    fileprivate var urlSession: MMTMeteorogramUrlSession!
    fileprivate var startDate: Date!    
    
    var forecastLength: Int {
        return 84
    }
    
    var gridNodeSize: Int {
        return 13
    }
    
    var forecastStartDate: Date {
        return startDate
    }
    
    var meteorogramSize: CGSize {
        return CGSize(width: 660, height: 570)
    }
    
    var legendSize: CGSize {
        return CGSize(width: 280, height: 570)
    }

    var detailedMapMeteorogramSize: CGSize {
        return CGSize(width: 590, height: 604)
    }

    var detailedMapMeteorogramLegendSize: CGSize {
        return CGSize(width: 128, height: 604)
    }
    
    var detailedMaps: [MMTDetailedMap] {
        return [
            .MeanSeaLevelPressure, .TemperatureAndStreamLine, .TemperatureOfSurface, .Precipitation, .Wind, .Visibility,
            .RelativeHumidity, .LowClouds, .MediumClouds, .HighClouds, .TotalCloudiness
        ]
    }
    
    // MARK: Initializers
    
    init(date: Date)
    {
        super.init()
        
        urlSession = MMTMeteorogramUrlSession(redirectionBaseUrl:  URL.mmt_modelCoampsDownloadBaseUrl())
        startDate = Calendar.utcCalendar.date(from: tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    func getMeteorogramForLocation(_ location: CLLocation, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        urlSession.fetchMeteorogramImageForUrl(URL.mmt_modelCoampsSearchUrl(location), completion: completion)
    }
    
    func getMeteorogramLegend(_ completion: @escaping MMTFetchMeteorogramCompletion)
    {        
        urlSession.fetchImageFromUrl(URL.mmt_modelCoampsLegendUrl(), completion: completion)
    }
    
    func getForecastStartDate(_ completion: @escaping MMTFetchForecastStartDateCompletion)
    {
        urlSession.fetchForecastStartDateFromUrl(URL.mmt_modelCoampsForecastStartUrl()) {
            (date: Date?, error: MMTError?) in            

            self.startDate = date ?? Calendar.utcCalendar.date(from: self.tZeroComponentsForDate(Date()))!
            completion(date, error)
        }
    }
    
    func getForecastMomentsForMap(_ map: MMTDetailedMap) -> [MMTWamMoment]
    {
        var moments = [MMTWamMoment]()
        let start = [.Precipitation, .Visibility, .LowClouds, .MediumClouds, .HighClouds, .TotalCloudiness].contains(map) ? 1 : 0
        
        for index in start...28 {
            let momentOffset = TimeInterval(hours: index*3)
            let momentDate = startDate.addingTimeInterval(momentOffset);
            
            moments.append((date: momentDate, selected: false))
        }
        
        return moments
    }
    
    func getMeteorogramForMap(_ map: MMTDetailedMap, moment: Date, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let tZeroPlus = getHoursFromForecastStartDate(forDate: moment)
        
        guard let downloadUrl = URL.mmt_modelCoampsDownloadUrlForMap(map, tZero: startDate, plus: tZeroPlus) else {
            
            completion(nil, .detailedMapNotSupported)
            return
        }
        
        urlSession.fetchImageFromUrl(downloadUrl, completion: completion)
    }
    
    // MARK: Helper methods
    
    private func getHoursFromForecastStartDate(forDate endDate: Date) -> Int
    {
        return Int(endDate.timeIntervalSince(startDate)/3600)
    }
    
    private func tZeroComponentsForDate(_ date: Date) -> DateComponents
    {
        let dateWithOffset = date.addingTimeInterval(-waitingTime)        

        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = components.hour! < 12 ? 0 : 12
        
        return components
    }
}
