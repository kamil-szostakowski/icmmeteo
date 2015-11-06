//
//  MMTMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics

public enum MMTClimateModel: String
{
    case UM = "model-um"
    case COAMPS = "model-coamps"
    case WAM = "model-wam"
    
    public var description: String
    {
        switch self
        {
            case .UM: return "Model UM"
            case .COAMPS: return "Model COAMPS"
            case .WAM: return "Model WAM"
        }
    }
}

protocol MMTClimateModelStore: NSObjectProtocol
{
    var meteorogramId: MMTClimateModel { get }
    
    var meteorogramSize: CGSize { get }
    
    var forecastLength: Int { get }
    
    var forecastStartDate: NSDate { get }
}