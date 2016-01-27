//
//  NSUserDefaults.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 28.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension NSUserDefaults
{
    private struct MMTUserDefaultsKey
    {
        static let Initialized = "Initialized"
    }
    
    // MARK: Properties
    
    var isAppInitialized: Bool
    {
        get { return valueForKey(MMTUserDefaultsKey.Initialized)?.boolValue ?? false }
        set
        {
            setValue(newValue, forKey: MMTUserDefaultsKey.Initialized)
            synchronize()
        }
    }
}