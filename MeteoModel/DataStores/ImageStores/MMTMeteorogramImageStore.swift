//
//  MMTMeteorogramImageStore.swift
//  MeteoModel
//
//  Created by szostakowskik on 25.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

protocol MMTMeteorogramImageStore
{
    var climateModel: MMTClimateModel { get }
    
    func getMeteorogram(for city: MMTCityProt, startDate: Date, completion: @escaping (MMTResult<UIImage>) -> Void)
    
    func getLegend(_ completion: @escaping (MMTResult<UIImage>) -> Void)
    
    func getMeteorogram(for map: MMTDetailedMap, moment: Date, startDate: Date, completion: @escaping (MMTResult<UIImage>) -> Void)
}
