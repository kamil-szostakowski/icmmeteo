//
//  MMTMeteorogramStore.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreGraphics

public class MMTClimateModelStore: NSObject
{
    public var meteorogramTitle: String { fatalError("") }
    
    public var meteorogramSize: CGSize { fatalError("") }
    
    public var forecastLength: Int { fatalError("") }
    
    public var forecastStartDate: NSDate { fatalError("") }    
}