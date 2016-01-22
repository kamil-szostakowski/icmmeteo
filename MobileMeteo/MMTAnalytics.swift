//
//  MMTAnalytics.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 22.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

enum MMTAnalyticsCategory: String
{
    case Locations
    case Meteorogram
}

enum MMTAnalyticsAction: String
{
    case MeteorogramDidDisplay
    case MeteorogramDidDisplayInLandscape
    
    case LocationDidAddToFavourites
    case LocationDidRemoveFromFavourites
    case LocationDidSelectCapital
    case LocationDidSelectFavourite
    case LocationDidSelectCurrentLocation
    case LocationDidSelectSearchResult
    case LocationDidSelectOnMap
    
    init?(group: MMTCityGroup)
    {
        switch group
        {
            case .Capitals: self = .LocationDidSelectCapital
            case .Favourites: self = .LocationDidSelectFavourite
            case .SearchResults: self = .LocationDidSelectSearchResult
            case .CurrentLocation: self = .LocationDidSelectCurrentLocation
        
            default: return nil
        }
    }
}

struct MMTAnalyticsReport
{
    var category: MMTAnalyticsCategory
    var action: MMTAnalyticsAction
    var actionLabel: String
}

protocol MMTAnalytics
{    
    func sendScreenEntryReport(screen: String)
    func sendUserActionReport(action: MMTAnalyticsReport)
    func sendUserActionReport(category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel: String)
}
