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
    case DetailedMaps
    case Shortcut
    case ForecasterComment
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
    case LocationDidSelectOnSpotlight
    case LocationDidChangeAuthorization
    case DetailedMapDidSelectModel
    case ShortcutSpotlightDidActivate
    case Shortcut3DTouchDidActivate
    case BackgroundUpdateDidFinish    
}

struct MMTAnalyticsReport
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

protocol MMTAnalytics
{    
    func sendScreenEntryReport(_ screen: String)
    func sendUserActionReport(_ action: MMTAnalyticsReport)
    func sendUserActionReport(_ category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel: String)
}

protocol MMTAnalyticsReporter
{
    var analytics: MMTAnalytics? { get }
}
