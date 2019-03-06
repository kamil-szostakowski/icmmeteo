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
import NotificationCenter

public let MMTDebugActionCleanupDb = "CLEANUP_DB"
public let MMTDebugActionSimulatedOfflineMode = "SIMULATED_OFFLINE_MODE"

@UIApplicationMain class MMTAppDelegate: UIResponder, UIApplicationDelegate, MMTAnalyticsReporter
{
    // MARK: Properties
    var window: UIWindow?
    var locationService: MMTCoreLocationService!
    var todayModelController: MMTTodayModelController!
    var navigator: MMTNavigator!
    
    var rootViewController: MMTTabBarController {
        return self.window!.rootViewController as! MMTTabBarController
    }
        
    // MARK: Lifecycle methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        UserDefaults.standard.importSettings()
        
        setupAppearance()
        setupAnalytics()
        setupLocationService()
        setupNavigator()
        setupTodayModelController()
        
        #if DEBUG
        setupDebugEnvironment()
        #endif
        
        if UserDefaults.standard.isAppInitialized == false {
            setupDatabase()
        }
        
        performMigration()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        let interval = UserDefaults.standard.widgetRefreshInterval
        UIApplication.shared.setMinimumBackgroundFetchInterval(interval)
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        MMTCoreData.instance.context.saveContextIfNeeded()
    }
    
    // MARK: External actions related methods
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        guard let destination = CSSearchableIndex.default().convert(from: userActivity)?.destination else {
            return false
        }
        
        navigator.navigate(to: destination) {}
        analytics?.sendUserActionReport(.Shortcut, action: .ShortcutSpotlightDidActivate)
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    {        
        guard let destination = UIApplication.shared.convert(from: shortcutItem)?.destination else {
            return
        }
        
        navigator.navigate(to: destination) { completionHandler(true) }
        analytics?.sendUserActionReport(.Shortcut, action: .Shortcut3DTouchDidActivate)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        todayModelController.onUpdate {
            if $0 == .newData {
                self.analytics?.sendUserActionReport(.Locations, action: .BackgroundUpdateDidFinish)
            }
            completionHandler(UIBackgroundFetchResult(updateStatus: $0))
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
        let attributes: [NSAttributedString.Key: Any] = [
            .font: MMTAppearance.boldFontWithSize(16),
            .foregroundColor: MMTAppearance.textColor
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: UIControl.State())
        
        let disabledAttributes: [NSAttributedString.Key: Any] = [
            .font: MMTAppearance.boldFontWithSize(16),
            .foregroundColor: UIColor.lightGray
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(disabledAttributes, for: UIControl.State.disabled)
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
    
    private func setupTodayModelController()
    {
        let forecastService = MMTMeteorogramForecastService(model: MMTUmClimateModel())
        todayModelController = MMTTodayModelController(forecastService, locationService)
    }
    
    private func setupLocationService()
    {
        let locationHandler = #selector(handleLocationDidChange(notification:))
        let authHandler = #selector(handleLocationAuthDidChange(notification:))
        
        NotificationCenter.default.addObserver(self, selector: locationHandler, name: .locationChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: authHandler, name: .locationAuthChangedNotification, object: nil)
        
        locationService = MMTCoreLocationService(CLLocationManager())
    }
    
    private func setupNavigator()
    {
        navigator = MMTNavigator(rootViewController, locationService)
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
    @objc func handleLocationAuthDidChange(notification: Notification)
    {
        let status = locationService.authorizationStatus
        let authorized = status == .whenInUse
        
        NCWidgetController().setHasContent(authorized, forWidgetWithBundleIdentifier: "com.szostakowski.meteo.MeteoWidget")
        analytics?.sendUserActionReport(.Locations, action: .LocationDidChangeAuthorization, actionLabel: status.description)
    }
    
    @objc func handleLocationDidChange(notification: Notification)
    {
        try? MMTShortcutsMigrator().migrate()
        todayModelController.onUpdate(completion: { _ in })
    }
}

extension UIApplication
{
    var locationService: MMTLocationService? {
        return (delegate as? MMTAppDelegate)?.locationService
    }
}
