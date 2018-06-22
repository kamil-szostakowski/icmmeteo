//
//  MMTMeteoDatabase.swift
//  MobileMeteo
//
//  Created by szostakowskik on 03.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreData

public class MMTCoreData
{
    // MARK: Properties
    public static private(set) var instance = MMTCoreData()    
    public var meteorogramsCache = MMTImagesCache(cache: NSCache<NSString, UIImage>())
    
    // MARK: CoreData stack
    lazy var model: NSManagedObjectModel =
        {
            let bundle = Bundle(for: MMTCoreData.self)
            let modelURL = bundle.url(forResource: "Mobile_Meteo", withExtension: "momd")
            return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator =
        {
            let type = NSSQLiteStoreType
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
            let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("Mobile_Meteo.sqlite")
            
            do { try coordinator.addPersistentStore(ofType: type, configurationName: nil, at: storeURL, options: nil) }
                
            catch let error as NSError {
                NSLog("CoreData fatal error: \(String(describing: error))")
                abort()
            }
            
            return coordinator
    }()
    
    public lazy var context: NSManagedObjectContext =
    {
        let
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return context
    }()
    
    public func flushDatabase()
    {
        self.context.performAndWait {
            self.meteorogramsCache.removeAllObjects()
            
            for store in self.persistentStoreCoordinator.persistentStores {
                _ = try? self.persistentStoreCoordinator.remove(store)
                _ = try? FileManager.default.removeItem(atPath: store.url!.path)
            }
            
            MMTCoreData.instance = MMTCoreData()
        }
    }
    
    // MARK: Helper methods
    private lazy var applicationDocumentsDirectory: URL =
    {
        let path = FileManager.SearchPathDirectory.documentDirectory
        let domain = FileManager.SearchPathDomainMask.userDomainMask
        
        return FileManager.default.urls(for: path, in: domain).last!
    }()
}

extension NSManagedObjectContext
{
    public func saveContextIfNeeded()
    {
        guard hasChanges == true else {
            return
        }
        
        try! save()
        NSLog("Context saved")
    }
}

