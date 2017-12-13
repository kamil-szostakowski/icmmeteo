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
import CoreLocation
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        MMTServiceProvider.locationService.start()        
        citiesStore = MMTCitiesStore(db: .instance, geocoder: MMTCityGeocoder(general: CLGeocoder()))
        
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(MMTDebugActionCleanupDb)
        {
            URLCache.shared.removeAllCachedResponses()
            MMTDatabase.instance.flushDatabase()
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
        }
            
        if ProcessInfo.processInfo.arguments.contains(MMTDebugActionSimulatedOfflineMode)
        {
            MMTMeteorogramUrlSession.simulateOfflineMode = true
        }
        #endif
        
        if !UserDefaults.standard.isAppInitialized {
            initDatabase()
        }
        
        setupAppearance()
        setupAnalytics()
        
        return true
    }    
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        MMTDatabase.instance.saveContext()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool
    {        
        guard let activityId = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return false }        
        guard let location = CSSearchableIndex.locationForSearchableCityUniqueId(activityId) else { return false }
        
        citiesStore.findCityForLocation(location) { (city: MMTCityProt?, error: MMTError?) in
            
            guard let selectedCity = city, error == nil else
            {
                let alert = UIAlertController.alertForMMTError(error!)
                self.rootViewController.present(alert, animated: true, completion: nil)
                return
            }
            
            let report = MMTAnalyticsReport(category: .Locations, action: .LocationDidSelectOnSpotlight, actionLabel: city!.name)
            
            self.rootViewController.presentMeteorogram(for: selectedCity)
            self.rootViewController.analytics?.sendUserActionReport(report)
        }        
        
        return true
    }
    
    // MARK: Setup methods
    
    private func setupAppearance()
    {
        let attributes: [NSAttributedStringKey: Any] = [
            .font: MMTAppearance.boldFontWithSize(16),
            .foregroundColor: MMTAppearance.textColor
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: UIControlState())
        
        let disabledAttributes: [NSAttributedStringKey: Any] = [
            .font: MMTAppearance.boldFontWithSize(16),
            .foregroundColor: UIColor.lightGray
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(disabledAttributes, for: UIControlState.disabled)
    }
    
    private func setupAnalytics()
    {        
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return
        }
        
        gai.tracker(withTrackingId: "UA-71334623-2")
        gai.trackUncaughtExceptions = false
    }
    
    // MARK: Helper methods
    
    private func initDatabase()
    {
        let filePath = Bundle.main.path(forResource: "Cities", ofType: "json")                        
        let cities = MMTPredefinedCitiesFileStore().getPredefinedCitiesFromFile(filePath!)
            
        for city in cities {
            guard let cityObject = city as? NSManagedObject else {
                continue
            }                
            MMTDatabase.instance.context.insert(cityObject)
        }
            
        MMTDatabase.instance.saveContext()
        UserDefaults.standard.isAppInitialized = true
    }    
}
