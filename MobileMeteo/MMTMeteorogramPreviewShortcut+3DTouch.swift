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
    convenience init(shortcut: MMTMeteorogramPreviewShortcut)
    {        
        let title = MMTLocalizedStringWithFormat("forecast: %@", shortcut.name)
        let subtitle = MMTLocalizedString(shortcut.region)
        let icon = UIApplicationShortcutIcon(type: .favorite)
        
        let userInfo: [String : Any] = [            
            "latitude" : shortcut.location.coordinate.latitude,
            "longitude" : shortcut.location.coordinate.longitude,
            "city-name" : shortcut.name,
            "city-region" : shortcut.region,
            "climate-model" : shortcut.climateModelType
        ]
        
        self.init(type: shortcut.identifier, localizedTitle: title, localizedSubtitle: subtitle, icon: icon, userInfo: userInfo)
    }
}

extension MMTMeteorogramPreviewShortcut
{
    convenience init?(shortcut: UIApplicationShortcutItem)
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
        
        guard
            let cmTypeString = shortcut.userInfo?["climate-model"] as? String,
            let model = MMTClimateModelType(rawValue: cmTypeString)?.model else {
            return nil
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let city = MMTCity(name: name, region: region, location: location)
        
        self.init(model: model, city: city)
    }
}
