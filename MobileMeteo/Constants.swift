//
//  Constants.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

struct MMTSegue
{
    static let UnwindToListOfCities = "UnwindToListOfCities"
    static let DisplayMeteorogram = "DisplayMeteorogram"
    static let DisplayWamSettings = "DisplayWamSettings"
}

struct MMTFormat
{
    static let TZeroPlus = "t0 +%03ldh"
    static let TZero = "%04ld%02ld%02ld%02ld"
}