//
//  MMTMeteorogramPreviewShortcut+QuickActions.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import CoreLocation

// 3D Touch, quick actions integration
extension UIApplicationShortcutItem
{
    convenience init(shortcut: MMTMeteorogramShortcut)
    {
        let subtitle = MMTLocalizedString(shortcut.region)
        let icon = UIApplicationShortcutIcon(type: .favorite)
        
        let userInfo: [String : Any] = [            
            "latitude" : shortcut.location.coordinate.latitude,
            "longitude" : shortcut.location.coordinate.longitude,
            "city-name" : shortcut.name,
            "city-region" : shortcut.region,
            "climate-model" : shortcut.climateModelType
        ]
        
        self.init(type: shortcut.identifier, localizedTitle: shortcut.name, localizedSubtitle: subtitle, icon: icon, userInfo: userInfo)
    }
}

extension MMTMeteorogramShortcut
{
    convenience init?(shortcut: UIApplicationShortcutItem)
    {
        guard let model = type(of: self).model(from: shortcut) else {
            return nil
        }

        guard let city = type(of: self).city(from: shortcut) else {
            return nil
        }
        
        self.init(model: model, city: city)
    }
}

extension MMTMeteorogramHereShortcut
{
    convenience init?(shortcut: UIApplicationShortcutItem, locationService: MMTLocationService)
    {
        guard let model = type(of: self).model(from: shortcut) else {
            return nil
        }        
        
        self.init(model: model, locationService: locationService)
    }
}

// Helper extension
extension MMTMeteorogramShortcut
{
    fileprivate static func model(from shortcut: UIApplicationShortcutItem) -> MMTClimateModel?
    {
        guard let cmTypeString = shortcut.userInfo?["climate-model"] as? String else {
            return nil
        }
        
        return MMTClimateModelType(rawValue: cmTypeString)?.model
    }
    
    fileprivate static func city(from shortcut: UIApplicationShortcutItem) -> MMTCityProt?
    {
        guard
            let latitude = shortcut.userInfo?["latitude"] as? CLLocationDegrees,
            let longitude = shortcut.userInfo?["longitude"] as? CLLocationDegrees else {
                return nil
        }
        
        guard let name = shortcut.userInfo?["city-name"] as? String else {
            return nil
        }
        
        guard let region = shortcut.userInfo?["city-region"] as? String else {
            return nil
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        return MMTCity(name: name, region: region, location: location)
    }

}
