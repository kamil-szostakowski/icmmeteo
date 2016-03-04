//
//  AppDelegate.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 15.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreSpotlight

public let MMTDebugActionCleanupDb = "CLEANUP_DB"
public let MMTDebugActionSimulatedOfflineMode = "SIMULATED_OFFLINE_MODE"

@UIApplicationMain class MMTAppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var citiesStore: MMTCitiesStore!
    
    var rootViewController: MMTTabBarController {
        return self.window!.rootViewController as! MMTTabBarController
    }
        
    // MARK: Delegate methods
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {        
        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        
        #if DEBUG
        if NSProcessInfo.processInfo().arguments.contains(MMTDebugActionCleanupDb)
        {
            MMTDatabase.instance.flushDatabase()
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
            NSUserDefaults.standardUserDefaults().synchronize()            
        }
            
        if NSProcessInfo.processInfo().arguments.contains(MMTDebugActionSimulatedOfflineMode)
        {
            MMTMeteorogramUrlSession.simulateOfflineMode = true
        }
        #endif
        
        if !NSUserDefaults.standardUserDefaults().isAppInitialized {
            initDatabase()
        }
        
        setupAppearance()
        setupAnalytics()
        
        return true
    }
    
    func applicationWillTerminate(application: UIApplication)
    {
        MMTDatabase.instance.saveContext()
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool
    {
        guard #available(iOS 9.0, *) else { return false }
        guard let activityId = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return false }        
        guard let location = CSSearchableIndex.locationForSearchableCityUniqueId(activityId) else { return false }
        
        citiesStore.findCityForLocation(location) { (city: MMTCityProt?, error: MMTError?) in
            
            guard error == nil && city != nil else
            {
                let alert = UIAlertController.alertForMMTError(error!)
                self.rootViewController.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            let report = MMTAnalyticsReport(category: .Locations, action: .LocationDidSelectOnSpotlight, actionLabel: city!.name)
            
            self.rootViewController.presentMeteorogramUmForCity(city!)
            self.rootViewController.analytics?.sendUserActionReport(report)
        }        
        
        return true
    }
    
    // MARK: Setup methods
    
    private func setupAppearance()
    {
        let attributes = [
            NSFontAttributeName: MMTAppearance.boldFontWithSize(16),
            NSForegroundColorAttributeName: MMTAppearance.textColor
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        
        let disabledAttributes = [
            NSFontAttributeName: MMTAppearance.boldFontWithSize(16),
            NSForegroundColorAttributeName: UIColor.lightGrayColor()
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(disabledAttributes, forState: UIControlState.Disabled)
    }
    
    private func setupAnalytics()
    {
        var error: NSError?
        GGLContext.sharedInstance().configureWithError(&error)
    }
    
    // MARK: Helper methods
    
    private func initDatabase()
    {
        let filePath = NSBundle.mainBundle().pathForResource("Cities", ofType: "json")
        let cities = MMTCitiesStore(db: MMTDatabase.instance).getPredefinedCitiesFromFile(filePath!)
            
        for city in cities
        {
            guard let cityObject = city as? NSManagedObject else {
                continue
            }
                
            MMTDatabase.instance.context.insertObject(cityObject)
        }
            
        MMTDatabase.instance.saveContext()
        NSUserDefaults.standardUserDefaults().isAppInitialized = true
    }    
}