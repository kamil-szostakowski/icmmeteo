//
//  NSError.swift
//  MobileMeteo
//
//  Created by Kamil on 09.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public enum MMTError: String, Error
{
    case meteorogramNotFound
    case meteorogramFetchFailure
    case forecastUndetermined
    case locationUnsupported
    case locationNotFound
    case locationServicesDisabled
    case mailNotAvailable
    case forecastStartDateNotFound
    case detailedMapNotSupported
    case urlNotAvailable
    case invalidMigrationChain
    case migrationFailure
    case commentFetchFailure
    case htmlFetchFailure
    case invalidMLInput
}
