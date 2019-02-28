//
//  MMTMeteorogramPreviewShortcut+QuickActions.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import CoreLocation
import MeteoModel
import MeteoUIKit

// 3D Touch, quick actions integration
extension UIApplicationShortcutItem
{
    convenience init(shortcut: MMTMeteorogramShortcut)
    {
        let subtitle = MMTLocalizedString(shortcut.city.region)
        let icon = UIApplicationShortcutIcon(type: .favorite)
        
        let userInfo: [String : NSSecureCoding] = [
            "latitude" : shortcut.city.location.coordinate.latitude as NSSecureCoding,
            "longitude" : shortcut.city.location.coordinate.longitude as NSSecureCoding,
            "city-name" : shortcut.city.name as NSSecureCoding,
            "city-region" : shortcut.city.region as NSSecureCoding,
            "climate-model" : shortcut.climateModel.type.rawValue as NSSecureCoding
        ]
        
        self.init(type: shortcut.identifier, localizedTitle: shortcut.city.name, localizedSubtitle: subtitle, icon: icon, userInfo: userInfo)
    }
}

extension MMTMeteorogramShortcut
{
    init?(shortcut: UIApplicationShortcutItem)
    {
        guard let model = shortcut.model, let city = shortcut.city else {
            return nil
        }
        
        self.init(model: model, city: city)
    }
}

// Helper extension
extension UIApplicationShortcutItem
{
    var model: MMTClimateModel?
    {
        guard let cmTypeString = userInfo?["climate-model"] as? String else {
            return nil
        }
        
        return MMTClimateModelType(rawValue: cmTypeString)?.model
    }
    
    var city: MMTCityProt?
    {
        guard
            let latitude = userInfo?["latitude"] as? CLLocationDegrees,
            let longitude = userInfo?["longitude"] as? CLLocationDegrees else {
                return nil
        }
        
        guard let name = userInfo?["city-name"] as? String else {
            return nil
        }
        
        guard let region = userInfo?["city-region"] as? String else {
            return nil
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        return MMTCityProt(name: name, region: region, location: location)
    }
}
