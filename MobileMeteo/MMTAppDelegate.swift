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
public let MMTDebugActionSkipOnboarding = "SKIP_ONBOARDING"
public let MMTBundleId = "com.szostakowski.meteo.MeteoWidget"

@UIApplicationMain class MMTAppDelegate: UIResponder, UIApplicationDelegate, MMTAnalyticsReporter
{
    // MARK: Properties
    var window: UIWindow?
    var todayModelController: MMTTodayModelController!
    var navigator: MMTNavigator!
    var factory: MMTFactory = MMTDefaultFactory()
    
    var rootViewController: MMTTabBarController {
        return window!.rootViewController as! MMTTabBarController
    }
        
    // MARK: Lifecycle methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        UserDefaults.standard.importSettings()
        NCWidgetController().setHasContent(true, forWidgetWithBundleIdentifier: MMTBundleId)
        
        application.setMinimumBackgroundFetchInterval(3600)
        
        setupAppearance()
        setupAnalytics()
        setupLocationService()
        
        navigator = MMTNavigator(rootViewController, factory.locationService)
        todayModelController = factory.createTodayModelController(.appForeground)
        
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
        MeteoModel.syncCaches()
        navigator.navigate(to: .onboarding(2)) {}
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
        // TODO: Should I cleanup cache when auth status changes?
        factory.createTodayModelController(.appBackground).onUpdate {
            self.analytics?.sendUserActionReport(.Locations, action: .BackgroundUpdateDidFinish)
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
        let url = Bundle.main.url(forResource: "Cities", withExtension: "json")
        
        MMTPredefinedCitiesFileStore().predefinedCities(from: url!).forEach {
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
        
        let
        page = UIPageControl.appearance()
        page.pageIndicatorTintColor = UIColor.lightGray
        page.currentPageIndicatorTintColor = MMTAppearance.meteoGreenColor
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
        let locationHandler = #selector(handleLocationDidChange(notification:))        
        NotificationCenter.default.addObserver(self, selector: locationHandler, name: .locationChangedNotification, object: nil)
    }
    
    private func performMigration()
    {
        let migrator = try? MMTAppMigrator(migrators: [MMTShortcutsMigrator()])
        try? migrator?.migrate(from: UserDefaults.standard.sequenceNumber)
    }
    
    #if DEBUG
    private func setupDebugEnvironment()
    {
        let arguments = ProcessInfo.processInfo.arguments
        
        if arguments.contains(MMTDebugActionCleanupDb) {
            URLCache.shared.removeAllCachedResponses()
            MMTCoreData.instance.flushDatabase()
            MeteoModel.cleanupCaches()            
            UserDefaults.standard.cleanup()
        }
        
        if arguments.contains(MMTDebugActionSkipOnboarding) {
            UserDefaults.standard.onboardingSequenceNumber = .max
        }
        
        if arguments.contains(MMTDebugActionSimulatedOfflineMode) {
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
        todayModelController.onUpdate(completion: { _ in })
    }
}

extension UIApplication
{
    var locationService: MMTLocationService? {
        return (delegate as? MMTAppDelegate)?.factory.locationService
    }
}
