//
//  UIApplication.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import UIKit

// MARK: Register extension
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
        
        shortcutItems?.append(item)
    }
    
    func unregister(_ shortcut: MMTShortcut)
    {
        guard let index = (shortcutItems?.firstIndex{ $0.type == shortcut.identifier }) else {
            return
        }
        
        shortcutItems?.remove(at: index)
    }
    
    func unregisterAll()
    {        
        shortcutItems?.removeAll()
    }

    func convert(from shortcut: MMTShortcut) -> UIApplicationShortcutItem?
    {
        if let currentLocationShortcut = shortcut as? MMTMeteorogramHereShortcut {
            return UIMutableApplicationShortcutItem(shortcut: currentLocationShortcut)
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
        if shortcut.type.hasPrefix("map") {
            return MMTDetailedMapShortcut(shortcut: shortcut)
        }
        
        if shortcut.type.hasPrefix("meteorogram") {
            return MMTMeteorogramShortcut(shortcut: shortcut)
        }
        
        if shortcut.type.hasPrefix("currentlocation") {
            return MMTMeteorogramHereShortcut(shortcut: shortcut)
        }
                
        return nil
    }
}
