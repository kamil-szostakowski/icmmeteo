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
    // MARK: Properties
    var window: UIWindow?
    var observation: NSKeyValueObservation?
    
    var rootViewController: MMTTabBarController {
        return self.window!.rootViewController as! MMTTabBarController
    }
        
    // MARK: Lifecycle methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        setupQuickActions()
        MMTServiceProvider.locationService.start()                
        //CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: nil)
        // TODO: Implement migration of spotlight and QuickActions
        #if DEBUG
        setupDebugEnvironment()
        #endif
        
        if UserDefaults.standard.isAppInitialized == false {
            setupDatabase()
        }
        
        setupAppearance()
        setupAnalytics()
        
        return true
    }    
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        MMTDatabase.instance.saveContext()
    }
    
    // MARK: External actions related methods
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool
    {
        let
        shortcut = CSSearchableIndex.default().convert(from: userActivity)
        shortcut?.execute(using: rootViewController, completion: nil)
        
        //let report = MMTAnalyticsReport(category: .Locations, action: .LocationDidSelectOnSpotlight, actionLabel: city!.name)
        //targetVC.analytics?.sendUserActionReport(report)
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    {        
        let
        shortcut = UIApplication.shared.convert(from: shortcutItem)
        shortcut?.execute(using: rootViewController) { completionHandler(true) }
    }    
}

// Setup extension
extension MMTAppDelegate
{
    // MARK: Setup methods
    private func setupDatabase()
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
    
    private func setupQuickActions()
    {
        let shortcut = MMTDetailedMapPreviewShortcut(model: MMTUmClimateModel(), map: .Precipitation)
        UIApplication.shared.register(shortcut)
        
        let service = MMTServiceProvider.locationService
        observation = service.observe(\.currentLocation) {(locationService, _) in
            
            let shortcut = MMTCurrentLocationMeteorogramPreviewShortcut(model: MMTUmClimateModel())
            
            if locationService.currentLocation != nil {
                UIApplication.shared.register(shortcut)
            } else {
                UIApplication.shared.unregister(shortcut)
            }
        }
    }
    
    #if DEBUG
    private func setupDebugEnvironment()
    {
        if ProcessInfo.processInfo.arguments.contains(MMTDebugActionCleanupDb) {
            URLCache.shared.removeAllCachedResponses()
            MMTDatabase.instance.flushDatabase()
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
        }
        
        if ProcessInfo.processInfo.arguments.contains(MMTDebugActionSimulatedOfflineMode) {
            MMTMeteorogramUrlSession.simulateOfflineMode = true
        }
    }
    #endif
}
