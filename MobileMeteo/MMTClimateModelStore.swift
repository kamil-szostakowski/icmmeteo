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

typealias MMTFetchMeteorogramCompletion = (_ data: Data?, _ error: MMTError?) -> Void
typealias MMTFetchForecastStartDateCompletion = (_ date: Date?, _ error: MMTError?) -> Void

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
    
    var detailedMaps: [MMTDetailedMap] { get }
    
    func getMeteorogramForLocation(_ location: CLLocation, completion: @escaping MMTFetchMeteorogramCompletion)
    
    func getMeteorogramLegend(_ completion: @escaping MMTFetchMeteorogramCompletion)
    
    func getForecastMomentsForMap(_ map: MMTDetailedMap) -> [MMTWamMoment]
    
    func getMeteorogramForMap(_ map: MMTDetailedMap, moment: Date, completion: @escaping MMTFetchMeteorogramCompletion)
}
