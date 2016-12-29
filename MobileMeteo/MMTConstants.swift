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
    static let UnwindToListOfDetailedMaps = "UnwindToListOfDetailedMaps"
    static let UnwindToWamModel = "UnwindToWamModel"
    static let DisplayMeteorogram = "DisplayMeteorogram"
    static let DisplayWamSettings = "DisplayWamSettings"
    static let DisplayWamCategoryPreview = "DisplayWamCategoryPreview"
    static let DisplayMapScreen = "DisplayMapScreen"
    static let DisplayDetailedMapsList = "DisplayDetailedMapsList"
    static let DisplayDetailedMap = "DisplayDetailedMap"
}

struct MMTFormat
{
    static let TZeroPlus = "t0 +%03ldh"
    static let TZero = "%04ld%02ld%02ld%02ld"
}

struct MMTFetch
{
    static let AllCities = "FetchAllCities"
    static let CityWithName = "FetchCityWithName"
    static let CityWithLocation = "FetchCityWithLocation"
}

protocol MMTGridClimateModelController
{
    var meteorogramStore: MMTGridClimateModelStore! { get set }
}

let MMTActivityTypeDisplayModelUm = "com.szostakowski.meteo.um"

let MMTTranslationCityCategory:[MMTCitiesIndexSectionType: String] =
[
    .CurrentLocation: MMTLocalizedString("locations.current"),
    .Favourites: MMTLocalizedString("locations.favourites"),
    .Capitals: MMTLocalizedString("locations.district-capitals"),
]

let  MMTTranslationWamCategory: [MMTWamCategory: String] =
[
    .TideHeight: MMTLocalizedString("model.wam.tide-height"),
    .AvgTidePeriod: MMTLocalizedString("model.wam.avg-tide-period"),
    .SpectrumPeakPeriod: MMTLocalizedString("model.wam.spectrum-peak-period"),
]

func MMTLocalizedString(_ string: String) -> String
{
    return NSLocalizedString(string, comment: "")
}

func MMTLocalizedStringWithFormat(_ format: String, _ arguments: CVarArg...) -> String
{
    return String(format: NSLocalizedString(format, comment: ""), arguments: arguments)
}
