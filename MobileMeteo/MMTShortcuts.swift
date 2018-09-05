//
//  MMTShortcuts.swift
//  MobileMeteo
//
//  Created by szostakowskik on 13.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

protocol MMTShortcut
{        
    var identifier: String { get }
    
    var destination: MMTNavigator.MMTDestination { get }    
}

protocol MMTShortcutRegister
{
    func register(_ shortcut: MMTShortcut)
    
    func unregister(_ shortcut: MMTShortcut)
    
    func unregisterAll()
}
