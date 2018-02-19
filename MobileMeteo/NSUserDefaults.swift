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
    private enum MMTUserDefaultsKey : String
    {
        case Initialized
        case SequenceNumber
    }
    
    // MARK: Properties
    var isAppInitialized: Bool
    {
        get { return value(forKey: .Initialized)?.boolValue ?? false }
        set {
            setValue(newValue, forKey: .Initialized)
            synchronize()
        }
    }
    
    var sequenceNumber: UInt
    {
        get { return value(forKey: .SequenceNumber)?.uintValue ?? 0 }
        set {
            setValue(newValue, forKey: .SequenceNumber)
            synchronize()
        }
    }
    
    // MARK: Methods
    func cleanup()
    {
        removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        synchronize()
    }
    
    // MARK: Helper methods
    private func value(forKey key: MMTUserDefaultsKey) -> AnyObject? {
        return value(forKey:key.rawValue) as AnyObject
    }
    
    private func setValue(_ value: Any?, forKey key: MMTUserDefaultsKey) {
        setValue(value, forKey: key.rawValue)
    }
}
