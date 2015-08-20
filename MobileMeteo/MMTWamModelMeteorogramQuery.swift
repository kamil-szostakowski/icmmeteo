//
//  MMTWamModelMeteorogramQuery.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public enum MMTWamCategory
{
    case TideHeight
    case AvgTidePeriod
    case SpectrumPeakPeriod
}

public class MMTWamModelMeteorogramQuery: NSObject
{
    // MARK: properties
    
    public let tZero: NSDate
    public let tZeroPlus: Int
    public let category: MMTWamCategory
    
    // MARK: initializers
    
    public init(category: MMTWamCategory, tZero: NSDate, tZeroPlus: Int)
    {
        self.tZero = tZero
        self.tZeroPlus = tZeroPlus
        self.category = category
        
        super.init()
    }
}