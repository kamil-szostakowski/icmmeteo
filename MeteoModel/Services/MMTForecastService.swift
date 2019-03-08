//
//  MMTForecastService.swift
//  MeteoModel
//
//  Created by szostakowskik on 29.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreLocation

public enum MMTUpdateResult
{
    case newData
    case noData
    case failed
}

public protocol MMTForecastService
{
    var currentMeteorogram: MMTMeteorogram? { get }
    
    func update(for location: MMTCityProt, completion: @escaping (MMTUpdateResult) -> Void)
}
