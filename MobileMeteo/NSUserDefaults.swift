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
        case OnboardingSequenceNumber
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
    
    var onboardingSequenceNumber: UInt {
        get { return value(forKey: .OnboardingSequenceNumber)?.uintValue ?? 0 }
        set {
            setValue(newValue, forKey: .OnboardingSequenceNumber)
            synchronize()
        }
    }
    
    // MARK: Methods
    func cleanup()
    {
        removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        synchronize()
    }
    
    func importSettings()
    {
        let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
        let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]
        
        var defaultsToRegister = Dictionary<String, Any>()
        
        for preference in preferences {
            guard let key = preference["Key"] as? String else { continue }
            defaultsToRegister[key] = preference["DefaultValue"]
        }
        
        register(defaults: defaultsToRegister)
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
