//
//  Constants.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

let MMTMeteorogramShortcutsLimit = 2

struct MMTFormat
{
    static let TZeroPlus = "t0 +%03ldh"
    static let TZero = "%04ld%02ld%02ld%02ld"
}

let MMTActivityTypeDisplayModelUm = "com.szostakowski.meteo.um"

let MMTTranslationCityCategory:[MMTCitiesIndexSectionType: String] =
[
    .CurrentLocation: MMTLocalizedString("locations.current"),
    .Favourites: MMTLocalizedString("locations.favourites"),
    .Capitals: MMTLocalizedString("locations.district-capitals"),
]

func MMTLocalizedString(_ string: String) -> String
{
    return NSLocalizedString(string, comment: "")
}

func MMTLocalizedStringWithFormat(_ format: String, _ arguments: CVarArg...) -> String
{
    return String(format: NSLocalizedString(format, comment: ""), arguments: arguments)
}
