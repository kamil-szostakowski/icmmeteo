//
//  MMTClimateModel.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01/01/17.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

enum MMTClimateModelType: String
{
    case UM
    case COAMPS
    case WAM
}

protocol MMTClimateModel
{
    var type: MMTClimateModelType { get }
    var forecastLength: Int { get }
    var gridNodeSize: Int { get }
    var availabilityDelay: TimeInterval { get }
    
    var detailedMapStartDelay: TimeInterval { get }
    var detailedMapMomentsCount: Int { get }
    var detailedMaps: [MMTDetailedMap] { get }

    func startDate(for date: Date) -> Date
}

class MMTUmClimateModel: MMTClimateModel
{
    let type = MMTClimateModelType.UM
    let forecastLength = 60
    let gridNodeSize = 4
    let availabilityDelay = TimeInterval(hours: 5)
    
    let detailedMapStartDelay = TimeInterval(hours: 1)
    let detailedMapMomentsCount = 20
    
    var detailedMaps: [MMTDetailedMap] { return [
        (.MeanSeaLevelPressure, 0), (.TemperatureAndStreamLine, 0), (.TemperatureOfSurface, 0), (.Precipitation, 1),
        (.Storm, 1), (.Wind, 0), (.MaximumGust, 1), (.Visibility, 0), (.Fog, 0), (.RelativeHumidityAboveIce, 0),
        (.RelativeHumidityAboveWater, 0), (.VeryLowClouds, 0), (.LowClouds, 0), (.MediumClouds, 0), (.HighClouds, 0),
        (.TotalCloudiness, 0),
    ]}
    
    func startDate(for date: Date) -> Date
    {
        let dateWithOffset = date.addingTimeInterval(-availabilityDelay)
        
        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = Int(components.hour!/6)*6
        
        return Calendar.utcCalendar.date(from: components)!
    }
}

class MMTCoampsClimateModel: MMTClimateModel
{
    let type = MMTClimateModelType.COAMPS
    let forecastLength = 84
    let gridNodeSize = 13
    let availabilityDelay = TimeInterval(hours: 6)
    
    let detailedMapStartDelay = TimeInterval(hours: 0)
    let detailedMapMomentsCount = 28
    
    var detailedMaps: [MMTDetailedMap] { return [
        (.MeanSeaLevelPressure, 0), (.TemperatureAndStreamLine, 0), (.TemperatureOfSurface, 0), (.Precipitation, 1), (.Wind, 0),
        (.Visibility, 1), (.RelativeHumidity, 0), (.LowClouds, 1), (.MediumClouds, 1), (.HighClouds, 1), (.TotalCloudiness, 1)
    ]}
    
    func startDate(for date: Date) -> Date
    {
        let dateWithOffset = date.addingTimeInterval(-availabilityDelay)
        
        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = components.hour! < 12 ? 0 : 12
        
        return Calendar.utcCalendar.date(from: components)!
    }
}

class MMTWamClimateModel: MMTClimateModel
{
    let type = MMTClimateModelType.WAM
    let forecastLength = 84
    let availabilityDelay = TimeInterval(hours: 7)
    let gridNodeSize = 0

    let detailedMapStartDelay = TimeInterval(hours: 0)
    let detailedMapMomentsCount = 28

    var detailedMaps: [MMTDetailedMap] { return [
        (.TideHeight, 1), (.AverageTidePeriod, 1), (.SpectrumPeakPeriod, 1)
    ]}

    func startDate(for date: Date) -> Date
    {
        let dateWithOffset = date.addingTimeInterval(-availabilityDelay)

        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = components.hour! < 12 ? 0 : 12

        return Calendar.utcCalendar.date(from: components)!
    }
}
