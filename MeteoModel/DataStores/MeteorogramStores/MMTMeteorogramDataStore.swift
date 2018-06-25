//
//  MMTMeteorogramDataStore.swift
//  MeteoModel
//
//  Created by szostakowskik on 25.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

public protocol MMTMeteorogramDataStore
{
    var climateModel: MMTClimateModel { get }
    
    func meteorogram(for city: MMTCityProt, completion: @escaping (MMTResult<MMTMeteorogram>) -> Void)
    
    func meteorogram(for map: MMTDetailedMap, completion: @escaping (MMTResult<MMTMapMeteorogram>) -> Void)
}
