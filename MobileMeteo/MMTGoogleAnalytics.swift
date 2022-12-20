//
//  MMTGoogleAnalytics.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 22.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import MeteoModel

extension MMTAnalyticsReporter
{
    var analytics: MMTAnalytics? {
        return nil
    }
}

extension UIViewController: MMTAnalyticsReporter {}

extension MMTAnalyticsAction
{
    init?(group: MMTCitiesIndexSectionType)
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
