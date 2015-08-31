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
    
    public var tintColor: UIColor
    {
        switch self
        {
            case .UM: return UIColor.redColor()
            case .COAMPS: return UIColor.greenColor()
            case .WAM: return UIColor.blueColor()
        }
    }
}

public class MMTClimateModelStore: NSObject
{
    public var meteorogramId: MMTClimateModel { fatalError("") }
    
    public var meteorogramSize: CGSize { fatalError("") }
    
    public var forecastLength: Int { fatalError("") }
    
    public var forecastStartDate: NSDate { fatalError("") }    
}