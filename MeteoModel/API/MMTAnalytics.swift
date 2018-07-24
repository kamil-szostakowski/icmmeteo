//
//  MMTAnalytics.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 22.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

public enum MMTAnalyticsCategory: String
{
    case Locations
    case Meteorogram
    case DetailedMaps
    case Shortcut
    case ForecasterComment
}

public enum MMTAnalyticsAction: String
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
    case LocationDidSelectOnSpotlight
    case LocationDidChangeAuthorization
    case DetailedMapDidSelectModel
    case ShortcutSpotlightDidActivate
    case Shortcut3DTouchDidActivate
    case BackgroundUpdateDidFinish
    
    public init?(group: MMTCitiesIndexSectionType)
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

public struct MMTAnalyticsReport
{
    public var category: MMTAnalyticsCategory
    public var action: MMTAnalyticsAction
    public var actionLabel: String
    
    public init(category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel: String)
    {
        self.category = category
        self.action = action
        self.actionLabel = actionLabel
    }
}

public protocol MMTAnalytics
{    
    func sendScreenEntryReport(_ screen: String)
    func sendUserActionReport(_ action: MMTAnalyticsReport)
    func sendUserActionReport(_ category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel: String)
}

public protocol MMTAnalyticsReporter
{
    var analytics: MMTAnalytics? { get }
}
