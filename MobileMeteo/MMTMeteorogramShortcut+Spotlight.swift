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
    // MARK: Initializers
    convenience init(shortcut: MMTMeteorogramShortcut)
    {
        let
        attributes = CSSearchableItemAttributeSet(itemContentType: MMTActivityTypeDisplayModelUm)
        attributes.contentDescription = "Prognoza pogody w modelu UM\nSiatka: 4km. Długość prognozy 60h"
        attributes.keywords = ["Pogoda", "Model UM", shortcut.city.name]
        attributes.displayName = "\(shortcut.city.name), \(shortcut.city.region)"
        
        self.init(uniqueIdentifier: shortcut.identifier, domainIdentifier: MMTActivityTypeDisplayModelUm, attributeSet: attributes)
        self.expirationDate = Date(timeIntervalSinceNow: 2592000.0)
    }
}

extension MMTMeteorogramShortcut
{
    init?(userActivity activity: NSUserActivity)
    {
        let idKey = CSSearchableItemActivityIdentifier
        
        guard let spotlightIdentifier = activity.userInfo?[idKey] as? String else {
            return nil
        }
        print(spotlightIdentifier)
        guard let components = CSSearchableItem.components(for: spotlightIdentifier) else {
            return nil
        }
        
        guard let location = CSSearchableItem.location(from: components.last!) else {
            return nil
        }
        
        guard let model = MMTClimateModelType(rawValue: components[1])?.model else {
            return nil
        }
        
        let city = MMTCityProt(name: components[2], region: components[3], location: location)
        self.init(model: model, city: city)
    }
}

extension CSSearchableItem
{
    // MARK: Helper methods
    fileprivate static func components(for spotlightIdentifier: String) -> [String]?
    {
        let components = spotlightIdentifier.components(separatedBy: "/")        
        guard components.count == 5 else { return nil }
        
        return components
    }
    
    fileprivate static func location(from component: String) -> CLLocation?
    {
        let locationComponents = component.components(separatedBy: ":")
        
        guard locationComponents.count == 2 else { return nil }
        guard let lat = CLLocationDegrees(locationComponents.first!) else { return nil }
        guard let lng = CLLocationDegrees(locationComponents.last!) else { return nil }
        
        return CLLocation(latitude: lat, longitude: lng)
    }
}
