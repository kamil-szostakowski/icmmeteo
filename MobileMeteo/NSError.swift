//
//  NSError.swift
//  MobileMeteo
//
//  Created by Kamil on 09.09.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public let MMTErrorDomain = "MMTErrorDomain"

public enum MMTError: Int
{
    case MeteorogramNotFound = 0
    case MeteorogramFetchFailure = 1
    case LocationUnsupported = 2
    case LocationNotFound = 3
    case LocationServicesDisabled = 4
    
    var description: String
    {
        switch self
        {
            case .MeteorogramNotFound: return "Nie udało się udnaleźć meteorogramu. Najprawdopodobniej nie został jeszcze przygotowany. Spróbuj ponownie później."
            case .MeteorogramFetchFailure: return "Nie udało się pobrać meteorogramu. Spróbuj ponownie później."
            case .LocationUnsupported: return "Wybrana lokacja nie jest obsługiwana."
            case .LocationNotFound: return "Nie udało się odnaleźć szczegółów lokalizacji. Wybierz inną lokalizację lub spróbuj ponownie później."
            case .LocationServicesDisabled: return "Aplikacja nie ma dostępu do Twojej lokalizacji. Aby korzystać z tej funkcji włącz usługi lokalizacji w ustawieniach aplikacji."
        }
    }
}

extension NSError
{
    convenience init(code: MMTError)
    {
        self.init(domain: MMTErrorDomain, code: code.rawValue, userInfo: nil)
    }
}