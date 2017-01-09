//
//  NSError.swift
//  MobileMeteo
//
//  Created by Kamil on 09.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

enum MMTError: Error
{
    case meteorogramNotFound
    case meteorogramFetchFailure
    case locationUnsupported
    case locationNotFound
    case mailNotAvailable
    case forecastStartDateNotFound
    case detailedMapNotSupported
    case urlNotAvailable
    
    var description: String?
    {
        switch self
        {
            case .meteorogramNotFound: return "Nie udało się odnaleźć meteorogramu. Najprawdopodobniej nie został jeszcze przygotowany. Spróbuj ponownie później."
            case .meteorogramFetchFailure: return "Nie udało się pobrać meteorogramu. Spróbuj ponownie później."
            case .locationUnsupported: return "Wybrana lokacja nie jest obsługiwana."
            case .locationNotFound: return "Nie udało się odnaleźć szczegółów lokalizacji. Wybierz inną lokalizację lub spróbuj ponownie później."
            case .mailNotAvailable: return "Zanim będziesz mógł przesłać nam swoją opinię, powinieneś skonfigurować swoją skrzynkę pocztową."
            
            default: return nil
        }
    }
}
