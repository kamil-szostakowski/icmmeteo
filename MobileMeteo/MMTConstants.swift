//
//  Constants.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import MeteoModel
import MeteoUIKit

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
