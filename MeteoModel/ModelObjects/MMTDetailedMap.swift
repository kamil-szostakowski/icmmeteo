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

public struct MMTDetailedMap
{
    public let climateModel: MMTClimateModel
    public let type: MMTDetailedMapType
    public let momentsOffset: Int
    
    init(_ model: MMTClimateModel, _ type: MMTDetailedMapType, _ offset: Int)
    {
        self.climateModel = model
        self.type = type
        self.momentsOffset = offset
    }
    
    func forecastMoments(for startDate: Date) -> [Date]
    {
        var moments = [Date]()
        
        for index in 0...climateModel.detailedMapMomentsCount {
            let momentOffset = index == 0 ? climateModel.detailedMapStartDelay : TimeInterval(hours: index*3)
            let momentDate = startDate.addingTimeInterval(momentOffset)
            
            moments.append(momentDate)
        }
        
        if momentsOffset < moments.count {
            return Array(moments[momentsOffset..<moments.count])
        }
        
        return []
    }
}
