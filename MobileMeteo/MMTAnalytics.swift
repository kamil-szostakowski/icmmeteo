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
    case Widget
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
    
    case WidgetDidDisplayCompact
    case WidgetDidDisplayExpanded
    case WidgetDidDisplayErrorNoLocationServices
    case WidgetDidDisplayErrorFetchFailure
}

struct MMTAnalyticsReport
{
    var category: MMTAnalyticsCategory
    var action: MMTAnalyticsAction
    var actionLabel: String
    
    init(category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel: String = "")
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
    func sendUserActionReport(_ category: MMTAnalyticsCategory, action: MMTAnalyticsAction)
    func sendUserActionReport(_ category: MMTAnalyticsCategory, action: MMTAnalyticsAction, actionLabel: String)
}

protocol MMTAnalyticsReporter
{
    var analytics: MMTAnalytics? { get }
}
