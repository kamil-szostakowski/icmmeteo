//
//  MMTMeteorogramPreviewShortcut+Spotlight.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import CoreLocation
import CoreSpotlight
import MeteoModel

// Spotlight search index integration
extension CSSearchableItem
{    
    convenience init(shortcut: MMTMeteorogramShortcut)
    {
        let
        attributes = CSSearchableItemAttributeSet(itemContentType: MMTActivityTypeDisplayModelUm)
        attributes.contentDescription = "Prognoza pogody w modelu UM\nSiatka: 4km. Długość prognozy 60h"
        attributes.keywords = ["Pogoda", "Model UM", shortcut.name]
        attributes.displayName = "\(shortcut.name), \(shortcut.region)"
        
        self.init(uniqueIdentifier: shortcut.identifier, domainIdentifier: MMTActivityTypeDisplayModelUm, attributeSet: attributes)
        self.expirationDate = Date(timeIntervalSinceNow: 2592000.0)
    }
    
    fileprivate static func location(for spotlightIdentifier: String) -> CLLocation?
    {
        guard let locationString = spotlightIdentifier.components(separatedBy: "-").last else {
            return nil
        }
        
        let locationComponents = locationString.components(separatedBy: ":")
        
        guard locationComponents.count == 2 else { return nil }
        guard let lat = CLLocationDegrees(locationComponents.first!) else { return nil }
        guard let lng = CLLocationDegrees(locationComponents.last!) else { return nil }
        
        return CLLocation(latitude: lat, longitude: lng)
    }
    
    fileprivate static func model(for spotlightIdentifier: String) -> MMTClimateModel?
    {
        let components = spotlightIdentifier.components(separatedBy: "-")
        
        guard components.count == 3 else {
            return nil
        }
        
        return MMTClimateModelType(rawValue: components[1])?.model
    }
}

extension MMTMeteorogramShortcut
{
    convenience init?(userActivity activity: NSUserActivity)
    {
        let idKey = CSSearchableItemActivityIdentifier
        
        guard let spotlightIdentifier = activity.userInfo?[idKey] as? String else {
            return nil
        }
        
        guard let location = CSSearchableItem.location(for: spotlightIdentifier) else {
            return nil
        }
        
        guard let model = CSSearchableItem.model(for: spotlightIdentifier) else {
            return nil
        }
        
        let city = MMTCityProt(name: "", region: "", location: location)
        self.init(model: model, city: city)
    }
}
