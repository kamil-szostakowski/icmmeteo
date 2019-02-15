//
//  MMTDetailedMapPreviewShortcut+QuickActions.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import MeteoModel
import MeteoUIKit

// 3D Touch, quick actions integration
extension UIApplicationShortcutItem
{
    convenience init(shortcut: MMTDetailedMapShortcut)
    {
        let icon = UIApplicationShortcutIcon(type: .cloud)
        let mapName = MMTLocalizedStringWithFormat("detailed-maps.\(shortcut.detailedMap.rawValue)")        
        
        let userInfo: [String : Any] = [
            "climate-model" : shortcut.climateModel.type.rawValue,
            "detailed-map" : shortcut.detailedMap.rawValue,
        ]
        
        self.init(type: shortcut.identifier, localizedTitle: mapName, localizedSubtitle: nil, icon: icon, userInfo: userInfo)
    }
}

extension MMTDetailedMapShortcut
{
    init?(shortcut: UIApplicationShortcutItem)
    {
        let value = { (key: String) -> String? in
            return shortcut.userInfo?[key] as? String
        }
        
        guard
            let cmTypeString = value("climate-model"),
            let model = MMTClimateModelType(rawValue: cmTypeString)?.model else {
                return nil
        }
        
        guard
            let dmTypeString = value("detailed-map"),
            let map = MMTDetailedMapType(rawValue: dmTypeString) else {
                return nil
        }
        
        self.init(model: model, map: map)
    }    
}
