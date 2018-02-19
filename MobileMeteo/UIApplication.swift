//
//  UIApplication.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

extension UIApplication : MMTShortcutRegister
{
    func register(_ shortcut: MMTShortcut)
    {
        guard (shortcutItems?.first { $0.type == shortcut.identifier }) == nil else {
            return
        }
        
        guard let item = convert(from: shortcut) else {
            return
        }
        
        if shortcut is MMTMeteorogramHereShortcut {
            shortcutItems?.append(item)
        } else {
            shortcutItems?.insert(item, at: 0)
        }
    }
    
    func unregister(_ shortcut: MMTShortcut)
    {
        guard let index = (shortcutItems?.index{ $0.type == shortcut.identifier }) else {
            return
        }
        
        shortcutItems?.remove(at: index)
    }

    func convert(from shortcut: MMTShortcut) -> UIApplicationShortcutItem?
    {
        if let currentLocationShortcut = shortcut as? MMTMeteorogramHereShortcut {
            let
            item = UIMutableApplicationShortcutItem(shortcut: currentLocationShortcut)
            item.icon = UIApplicationShortcutIcon(type: .location)
            return item
        }
        
        if let meteorogramShortcut = shortcut as? MMTMeteorogramShortcut {
            return UIApplicationShortcutItem(shortcut: meteorogramShortcut)
        }
        
        if let mapShortcut = shortcut as? MMTDetailedMapShortcut {
            return UIApplicationShortcutItem(shortcut: mapShortcut)
        }
        
        return nil
    }
    
    func convert(from shortcut: UIApplicationShortcutItem) -> MMTShortcut?
    {
        if shortcut.type.contains("map-") {
            return MMTDetailedMapShortcut(shortcut: shortcut)
        }
        
        if shortcut.type.contains("meteorogram-") {
            return MMTMeteorogramShortcut(shortcut: shortcut)
        }
        
        if shortcut.type.contains("current-location") {
            return MMTMeteorogramHereShortcut(shortcut: shortcut, locationService: UIApplication.shared.locationService!)
        }
                
        return nil
    }
}
