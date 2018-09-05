//
//  MMTMeteorogramHereShortcut+3DTouch.swift
//  MobileMeteo
//
//  Created by szostakowskik on 01.08.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import MeteoModel

extension UIApplicationShortcutItem
{
    convenience init(shortcut: MMTMeteorogramHereShortcut)
    {
        let title = MMTLocalizedString("forecast.here")
        let icon = UIApplicationShortcutIcon(type: .location)
        let userInfo: [String : Any] = ["climate-model": shortcut.climateModel.type.rawValue]
        
        self.init(type: shortcut.identifier, localizedTitle: title, localizedSubtitle: nil, icon: icon, userInfo: userInfo)
    }
}

extension MMTMeteorogramHereShortcut
{
    init?(shortcut: UIApplicationShortcutItem)
    {
        guard shortcut.type == "currentlocation" else {
            return nil
        }
        
        guard let model = shortcut.model else {
            return nil
        }
        
        self.init(model: model)
    }
}
