//
//  NSUserDefaults.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 28.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

extension UserDefaults
{
    fileprivate struct MMTUserDefaultsKey
    {
        static let Initialized = "Initialized"
    }
    
    // MARK: Properties
    
    var isAppInitialized: Bool
    {
        get { return (value(forKey: MMTUserDefaultsKey.Initialized) as AnyObject).boolValue ?? false }
        set
        {
            setValue(newValue, forKey: MMTUserDefaultsKey.Initialized)
            synchronize()
        }
    }
}
