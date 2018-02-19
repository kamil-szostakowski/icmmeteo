//
//  CSSearchableIndex.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 26.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import CoreSpotlight

extension CSSearchableIndex : MMTShortcutRegister
{    
    func register(_ shortcut: MMTShortcut)
    {
        guard let item = convert(from: shortcut) else {
            return
        }
        
        indexSearchableItems([item], completionHandler: nil)
    }
    
    func unregister(_ shortcut: MMTShortcut)
    {
        deleteSearchableItems(withIdentifiers: [shortcut.identifier], completionHandler: nil)
    }
    
    func convert(from shortcut: MMTShortcut) -> CSSearchableItem?
    {
        if let meteorogramShortcut = shortcut as? MMTMeteorogramShortcut {
            return CSSearchableItem(shortcut: meteorogramShortcut)
        }
        
        return nil
    }
    
    func convert(from activity: NSUserActivity) -> MMTShortcut?
    {
        return MMTMeteorogramShortcut(userActivity: activity)
    }
}
