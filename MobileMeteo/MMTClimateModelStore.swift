//
//  MMTMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreGraphics

typealias MMTFetchMeteorogramCompletion = (_ image: UIImage?, _ error: MMTError?) -> Void
typealias MMTFetchForecastStartDateCompletion = (_ date: Date?, _ error: MMTError?) -> Void
typealias MMTFetchMeteorogramsCompletion = (_ image: UIImage?, _ date: Date?, _ error: MMTError?, _ finish: Bool) -> Void

enum MMTDetailedMap: String
{
    case MeanSeaLevelPressure
    case TemperatureAndStreamLine
    case TemperatureOfSurface
    case Precipitation
    case Storm
    case Wind
    case MaximumGust
    case Visibility
    case Fog
    case RelativeHumidity
    case RelativeHumidityAboveIce
    case RelativeHumidityAboveWater
    case VeryLowClouds
    case LowClouds
    case MediumClouds
    case HighClouds
    case TotalCloudiness
}

protocol MMTClimateModelStore
{    
    var meteorogramSize: CGSize { get }
    
    var forecastLength: Int { get }
    
    var forecastStartDate: Date { get }
    
    func getForecastStartDate(_ completion: @escaping MMTFetchForecastStartDateCompletion)
}

protocol MMTGridClimateModelStore: MMTClimateModelStore
{
    var gridNodeSize: Int { get }
    
    var legendSize: CGSize { get }
    
    func getMeteorogramForLocation(_ location: CLLocation, completion: @escaping MMTFetchMeteorogramCompletion)
    
    func getMeteorogramLegend(_ completion: @escaping MMTFetchMeteorogramCompletion)
}

protocol MMTDetailedMapsStore
{
    var detailedMaps: [MMTDetailedMap] { get }

    var detailedMapMeteorogramLegendSize: CGSize { get }

    var detailedMapMeteorogramSize: CGSize { get }

    func getForecastMomentsForMap(_ map: MMTDetailedMap) -> [MMTWamMoment]

    func getMeteorogramForMap(_ map: MMTDetailedMap, moment: Date, completion: @escaping MMTFetchMeteorogramCompletion)
}

extension MMTDetailedMapsStore
{
    func getMeteorograms(for moments: [MMTWamMoment], map: MMTDetailedMap, completion: @escaping MMTFetchMeteorogramsCompletion)
    {
        let queue = DispatchQueue.global()
        let group = DispatchGroup()        

        for (date, _) in moments
        {
            queue.async(group: group) {
                group.enter()

                self.getMeteorogramForMap(map, moment: date) {
                    (image: UIImage?, error: MMTError?) in
                    NSLog("XXX: date: \(date) image: \(image) error: \(error)")
                    DispatchQueue.main.async { completion(image, date, error, false) }
                    group.leave()
                }
            }
        }

        group.notify(queue: queue) {
            DispatchQueue.main.async { completion(nil, nil, nil, true) }
        }
    }
}
