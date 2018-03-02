//
//  MMTDatabase.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 15.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreData

public class MMTDatabase
{
    // MARK: Properties
    public static private(set) var instance = MMTDatabase()
    
    public var meteorogramsCache = NSCache<NSString, UIImage>()
    
    // MARK: CoreData stack
    public lazy var model: NSManagedObjectModel =
    {
        let bundle = Bundle(for: type(of: self))
        let modelURL = bundle.url(forResource: "Mobile_Meteo", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator =
    {
        let type = NSSQLiteStoreType
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("Mobile_Meteo.sqlite")
        
        do { try coordinator.addPersistentStore(ofType: type, configurationName: nil, at: storeURL, options: nil) }
        
        catch let error as NSError {
            self.reportFatalError(error)
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
    
    public func saveContext()
    {
        if context.hasChanges {
            do
            {
                try context.save()
                NSLog("Context saved")
            }
            catch let error as NSError {
                reportFatalError(error)
            }
        }        
    }
    
    public func flushDatabase()
    {
        self.context.performAndWait {
            self.meteorogramsCache.removeAllObjects()

            for store in self.persistentStoreCoordinator.persistentStores {
                _ = try? self.persistentStoreCoordinator.remove(store)
                _ = try? FileManager.default.removeItem(atPath: store.url!.path)
            }
            
            MMTDatabase.instance = MMTDatabase()
        }
    }
    
    // MARK: Helper methods
    private lazy var applicationDocumentsDirectory: URL =
    {
        let path = FileManager.SearchPathDirectory.documentDirectory
        let domain = FileManager.SearchPathDomainMask.userDomainMask
        
        return FileManager.default.urls(for: path, in: domain).last!
    }()
    
    private func reportFatalError(_ error: NSError?)
    {
        NSLog("CoreData fatal error: \(String(describing: error))")
        abort()
    }
}

extension MMTDatabase: MMTEntityFactory
{
    public func createCity() -> MMTCityProt {
        return MMTCity(entity: MMTCity.entityDescription, insertInto: nil)
    }
}


