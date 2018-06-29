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
import MeteoModel

public let MMTDebugActionCleanupDb = "CLEANUP_DB"
public let MMTDebugActionSimulatedOfflineMode = "SIMULATED_OFFLINE_MODE"

@UIApplicationMain class MMTAppDelegate: UIResponder, UIApplicationDelegate, MMTAnalyticsReporter
{
    // MARK: Properties
    var window: UIWindow?
    var locationService: MMTCoreLocationService!
    var forecastService = MMTMeteorogramForecastService(model: MMTUmClimateModel())
    
    var rootViewController: MMTTabBarController {
        return self.window!.rootViewController as! MMTTabBarController
    }
        
    // MARK: Lifecycle methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        setupAppearance()
        setupAnalytics()
        setupLocationService()
        
        #if DEBUG
        setupDebugEnvironment()
        #endif
        
        if UserDefaults.standard.isAppInitialized == false {
            setupDatabase()
        }
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
        performMigration()
        
        return true
    }    
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        MMTCoreData.instance.context.saveContextIfNeeded()
    }
    
    // MARK: External actions related methods
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool
    {
        let
        shortcut = CSSearchableIndex.default().convert(from: userActivity)
        shortcut?.execute(using: rootViewController, completion: nil)
        
        analytics?.sendUserActionReport(.Shortcut, action: .ShortcutSpotlightDidActivate, actionLabel: "")
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    {        
        let
        shortcut = UIApplication.shared.convert(from: shortcutItem)
        shortcut?.execute(using: rootViewController) { completionHandler(true) }
        
        rootViewController.analytics?.sendUserActionReport(.Shortcut, action: .Shortcut3DTouchDidActivate, actionLabel: "")
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        forecastService.update(for: locationService.currentLocation) { status in
            if status == .newData {
                self.analytics?.sendUserActionReport(.Locations, action: .BackgroundUpdateDidFinish, actionLabel: "")
            }
            completionHandler(UIBackgroundFetchResult(updateStatus: status))
        }
    }
}

// Setup extension
extension MMTAppDelegate
{
    // MARK: Setup methods
    private func setupDatabase()
    {
        let coreDataStore = MMTCoreDataCitiesStore()
        let filePath = Bundle.main.path(forResource: "Cities", ofType: "json")
        
        MMTPredefinedCitiesFileStore().predefinedCities(from: filePath!).forEach {
            coreDataStore.save(city: $0)
        }
        
        UserDefaults.standard.isAppInitialized = true
        MMTCoreData.instance.context.saveContextIfNeeded()
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
    
    private func setupLocationService()
    {
        let handler = #selector(handleLocationDidChange(notification:))
        NotificationCenter.default.addObserver(self, selector: handler, name: .locationChangedNotification, object: nil)
        
        locationService = MMTCoreLocationService(locationManager: CLLocationManager())
        locationService.analytics = analytics
    }
    
    private func performMigration()
    {
        let migrator = try? MMTAppMigrator(migrators: [MMTShortcutsMigrator()])
        try? migrator?.migrate(from: UserDefaults.standard.sequenceNumber)
    }
    
    #if DEBUG
    private func setupDebugEnvironment()
    {
        if ProcessInfo.processInfo.arguments.contains(MMTDebugActionCleanupDb) {
            URLCache.shared.removeAllCachedResponses()
            MMTCoreData.instance.flushDatabase()
            UserDefaults.standard.cleanup()
        }
        
        if ProcessInfo.processInfo.arguments.contains(MMTDebugActionSimulatedOfflineMode) {
            MMTMeteorogramUrlSession.simulateOfflineMode = true
        }
    }
    #endif
}

// Location service extension
extension MMTAppDelegate
{
    
    @objc func handleLocationDidChange(notification: Notification)
    {
        try? MMTShortcutsMigrator().migrate()
        forecastService.update(for: locationService.currentLocation, completion: { _ in })
    }
}

extension UIApplication
{
    var locationService: MMTLocationService? {
        return (delegate as? MMTAppDelegate)?.locationService
    }
}
