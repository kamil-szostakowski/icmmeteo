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

enum MMTClimateModel: String
{
    case UM = "model-um"
    case COAMPS = "model-coamps"
    case WAM = "model-wam"
    
    var description: String
    {
        switch self
        {
            case .UM: return "Model UM"
            case .COAMPS: return "Model COAMPS"
            case .WAM: return "Model WAM"
        }
    }
}

protocol MMTClimateModelStore
{
    var meteorogramId: MMTClimateModel { get }
    
    var meteorogramSize: CGSize { get }
    
    var forecastLength: Int { get }
    
    var forecastStartDate: NSDate { get }
}

protocol MMTGridClimateModelStore: MMTClimateModelStore
{
    var gridNodeSize: Int { get }
    
    var legendSize: CGSize { get }
    
    func getMeteorogramForLocation(location: CLLocation, completion: MMTFetchMeteorogramCompletion)
    
    func getMeteorogramLegend(completion: MMTFetchMeteorogramCompletion)
}
