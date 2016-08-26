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
    
    fileprivate let waitingTime = TimeInterval(hours: 5)
    fileprivate var urlSession: MMTMeteorogramUrlSession!
    fileprivate var startDate: Date!
    
    var forecastLength: Int {
        return 60
    }
    
    var gridNodeSize: Int {
        return 4
    }
    
    var forecastStartDate: Date {
        return startDate
    }
    
    var meteorogramSize: CGSize {
        return CGSize(width: 540, height: 660)
    }
    
    var legendSize: CGSize {
        return CGSize(width: 280, height: 660)
    }
    
    var detailedMaps: [MMTDetailedMap] {
        return [
            .MeanSeaLevelPressure, .TemperatureAndStreamLine, .TemperatureOfSurface, .Precipitation, .Storm, .Wind, .MaximumGust, .Visibility, .Fog,
            .RelativeHumidityAboveIce, .RelativeHumidityAboveWater, .VeryLowClouds, .LowClouds, .MediumClouds, .HighClouds, .TotalCloudiness
        ]
    }
    
    // MARK: Initializers
    
    init(date: Date)
    {
        super.init()
        
        urlSession = MMTMeteorogramUrlSession(redirectionBaseUrl: URL.mmt_modelUmDownloadBaseUrl())
        startDate = Calendar.utcCalendar.date(from: tZeroComponentsForDate(date))!
    }
    
    // MARK: Methods
    
    func getMeteorogramForLocation(_ location: CLLocation, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        urlSession.fetchMeteorogramImageForUrl(URL.mmt_modelUmSearchUrl(location), completion: completion)
    }
    
    func getMeteorogramLegend(_ completion: @escaping MMTFetchMeteorogramCompletion)
    {        
        urlSession.fetchImageFromUrl(URL.mmt_modelUmLegendUrl(), completion: completion)
    }
    
    func getForecastStartDate(_ completion: @escaping MMTFetchForecastStartDateCompletion)
    {
        urlSession.fetchForecastStartDateFromUrl(URL.mmt_modelUmForecastStartUrl()) {
            (date: Date?, error: MMTError?) in            
            
            self.startDate = date ?? Calendar.utcCalendar.date(from: self.tZeroComponentsForDate(Date()))!
            completion(date, error)
        }
    }
    
    func getForecastMomentsForMap(_ map: MMTDetailedMap) -> [MMTWamMoment]
    {
        // TODO: Add +1 hour for standard maps
        var moments = [MMTWamMoment]()
        let start = [.Precipitation, .Storm, .MaximumGust].contains(map) ? 1 : 0
        
        for index in start...20 {
            
            let momentOffset = TimeInterval(hours: max(index*3, 1))
            let momentDate = startDate.addingTimeInterval(momentOffset)
            
            moments.append((date: momentDate, selected: false))
        }
        
        return moments
    }
    
    func getMeteorogramForMap(_ map: MMTDetailedMap, moment: Date, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let tZeroPlus = getHoursFromForecastStartDate(forDate: moment)
        
        guard let downloadUrl = URL.mmt_modelUmDownloadUrlForMap(map, tZero: startDate, plus: tZeroPlus) else {
            
            completion(nil, .detailedMapNotSupported)
            return
        }
        //http://www.meteo.pl/um/pict/2016120212/SLPH_0000.0_0U_2016120212_001-00.png
        //http://www.meteo.pl/um/pict/2016120212/SLPH_0000.0_0U_2016120212_000-00.png
        urlSession.fetchImageFromUrl(downloadUrl, completion: completion)
    }
    
    // MARK: Helper methods    
    
    fileprivate func getHoursFromForecastStartDate(forDate endDate: Date) -> Int
    {
        return Int(endDate.timeIntervalSince(startDate)/3600)
    }
    
    fileprivate func tZeroComponentsForDate(_ date: Date) -> DateComponents
    {
        let dateWithOffset = date.addingTimeInterval(-waitingTime)
        
        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = Int(components.hour!/6)*6

        return components
    }    
}
