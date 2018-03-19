//
//  MMTDetailedMap.swift
//  MobileMeteo
//
//  Created by Kamil on 11.01.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

public enum MMTDetailedMapType: String
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
    case TideHeight
    case AverageTidePeriod
    case SpectrumPeakPeriod
}

public typealias MMTDetailedMap = (type: MMTDetailedMapType, momentsOffset: Int)
