//
//  AppDelegate.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 15.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
        
    // MARK: Delegate methods
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        tryInitDatabase()
        
        return true
    }
    
    func applicationWillTerminate(application: UIApplication)
    {
        MMTDatabase.instance.saveContext()
    }
    
    // MARK: Helper methods
    
    private func tryInitDatabase()
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.valueForKey("Initialized") == nil
        {
            let filePath = NSBundle.mainBundle().pathForResource("Cities", ofType: "json")            
            let cities = MMTCitiesStore(db: MMTDatabase.instance).getPredefinedCitiesFromFile(filePath!)
            
            for city in cities {
                MMTDatabase.instance.managedObjectContext.insertObject(city)
            }
            
            MMTDatabase.instance.saveContext()
            
            userDefaults.setBool(true, forKey: "Initialized")
            userDefaults.synchronize()
        }
    }
}