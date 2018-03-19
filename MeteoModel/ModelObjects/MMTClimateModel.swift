//
//  MMTClimateModel.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01/01/17.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

public enum MMTClimateModelType: String
{
    case UM
    case COAMPS
    case WAM
}

extension MMTClimateModelType
{
    public var model: MMTClimateModel {
        switch self {
        case .UM: return MMTUmClimateModel()
        case .COAMPS: return MMTCoampsClimateModel()
        case .WAM: return MMTWamClimateModel()
        }
    }
}

public protocol MMTClimateModel
{
    var type: MMTClimateModelType { get }
    var forecastLength: Int { get }
    var gridNodeSize: Int { get }
    var availabilityDelay: TimeInterval { get }
    
    var detailedMapStartDelay: TimeInterval { get }
    var detailedMapMomentsCount: Int { get }
    var detailedMaps: [MMTDetailedMap] { get }

    func startDate(for date: Date) -> Date
    func detailedMap(ofType: MMTDetailedMapType) -> MMTDetailedMap?
}

extension MMTClimateModel
{
    public func detailedMap(ofType type: MMTDetailedMapType) -> MMTDetailedMap?
    {
        return detailedMaps.first { $0.type == type }
    }
}

public struct MMTUmClimateModel: MMTClimateModel
{
    public let type = MMTClimateModelType.UM
    public let forecastLength = 60
    public let gridNodeSize = 4
    public let availabilityDelay = TimeInterval(hours: 5)
    
    public let detailedMapStartDelay = TimeInterval(hours: 1)
    public let detailedMapMomentsCount = 20
    
    public var detailedMaps: [MMTDetailedMap] { return [
        (.MeanSeaLevelPressure, 0), (.TemperatureAndStreamLine, 0), (.TemperatureOfSurface, 0), (.Precipitation, 1),
        (.Storm, 1), (.Wind, 0), (.MaximumGust, 1), (.Visibility, 0), (.Fog, 0), (.RelativeHumidityAboveIce, 0),
        (.RelativeHumidityAboveWater, 0), (.VeryLowClouds, 0), (.LowClouds, 0), (.MediumClouds, 0), (.HighClouds, 0),
        (.TotalCloudiness, 0),
    ]}
    
    public init() {}
    
    public func startDate(for date: Date) -> Date
    {
        let dateWithOffset = date.addingTimeInterval(-availabilityDelay)
        
        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = Int(components.hour!/6)*6
        
        return Calendar.utcCalendar.date(from: components)!
    }
}

public struct MMTCoampsClimateModel: MMTClimateModel
{
    public let type = MMTClimateModelType.COAMPS
    public let forecastLength = 84
    public let gridNodeSize = 13
    public let availabilityDelay = TimeInterval(hours: 6)
    
    public let detailedMapStartDelay = TimeInterval(hours: 0)
    public let detailedMapMomentsCount = 28
    
    public var detailedMaps: [MMTDetailedMap] { return [
        (.MeanSeaLevelPressure, 0), (.TemperatureAndStreamLine, 0), (.TemperatureOfSurface, 0), (.Precipitation, 1), (.Wind, 0),
        (.Visibility, 1), (.RelativeHumidity, 0), (.LowClouds, 1), (.MediumClouds, 1), (.HighClouds, 1), (.TotalCloudiness, 1)
    ]}
    
    public init() {}
    
    public func startDate(for date: Date) -> Date
    {
        let dateWithOffset = date.addingTimeInterval(-availabilityDelay)
        
        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = components.hour! < 12 ? 0 : 12
        
        return Calendar.utcCalendar.date(from: components)!
    }
}

public struct MMTWamClimateModel: MMTClimateModel
{
    public let type = MMTClimateModelType.WAM
    public let forecastLength = 84
    public let availabilityDelay = TimeInterval(hours: 7)
    public let gridNodeSize = 0

    public let detailedMapStartDelay = TimeInterval(hours: 0)
    public let detailedMapMomentsCount = 28

    public var detailedMaps: [MMTDetailedMap] { return [
        (.TideHeight, 1), (.AverageTidePeriod, 1), (.SpectrumPeakPeriod, 1)
    ]}

    public init() {}
    
    public func startDate(for date: Date) -> Date
    {
        let dateWithOffset = date.addingTimeInterval(-availabilityDelay)

        var
        components = Calendar.utcCalendar.dateComponents([.year, .month, .day, .hour], from: dateWithOffset)
        components.hour = components.hour! < 12 ? 0 : 12

        return Calendar.utcCalendar.date(from: components)!
    }
}
