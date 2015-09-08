//
//  Constants.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public let MMTErrorDomain = "MMTErrorDomain"

public enum MMTError: Int
{
    case MeteorogramNotFound = 0
    case MeteorogramFetchFailure = 1
    
    var description: String
    {
        switch self
        {
            case .MeteorogramNotFound: return "Nie udało się udnaleźć meteorogramu. Najprawdopodobniej nie został jeszcze przygotowany. Spróbuj ponownie później."
            case .MeteorogramFetchFailure: return "Nie udało się pobrać meteorogramu. Spróbuj ponownie później."
        }
    }
}

struct MMTSegue
{
    static let UnwindToListOfCities = "UnwindToListOfCities"
    static let DisplayMeteorogram = "DisplayMeteorogram"
    static let DisplayWamSettings = "DisplayWamSettings"
    static let DisplayWamCategoryPreview = "DisplayWamCategoryPreview"
    static let DisplayMapScreen = "DisplayMapScreen"
}

struct MMTFormat
{
    static let TZeroPlus = "t0 +%03ldh"
    static let TZero = "%04ld%02ld%02ld%02ld"
}