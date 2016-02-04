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

typealias MMTFetchMeteorogramCompletion = (data: NSData?, error: MMTError?) -> Void
typealias MMTFetchForecastStartDateCompletion = (date: NSDate?, error: MMTError?) -> Void

protocol MMTClimateModelStore
{    
    var meteorogramSize: CGSize { get }
    
    var forecastLength: Int { get }
    
    var forecastStartDate: NSDate { get }
    
    func getForecastStartDate(completion: MMTFetchForecastStartDateCompletion)
}

protocol MMTGridClimateModelStore: MMTClimateModelStore
{
    var gridNodeSize: Int { get }
    
    var legendSize: CGSize { get }
    
    func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion)
    
    func getMeteorogramLegend(completion: MMTFetchMeteorogramCompletion)
}
