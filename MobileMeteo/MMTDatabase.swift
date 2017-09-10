//
//  MMTDatabase.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 15.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreData

class MMTDatabase: NSObject
{
    // MARK: Properties

    static fileprivate(set) var instance = MMTDatabase()

    var detailedMapsCache = NSCache<NSString, UIImage>()
    
    // MARK: CoreData stack
    
    lazy var model: NSManagedObjectModel =
    {
        let modelURL = Bundle.main.url(forResource: "Mobile_Meteo", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator =
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
    
    lazy var context: NSManagedObjectContext =
    {
        let
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator

        return context
    }()
    
    func saveContext()
    {
        if context.hasChanges
        {
            do { try context.save()
                NSLog("Context saved")
            }
                
            catch let error as NSError {
                reportFatalError(error)
            }
        }        
    }
    
    func flushDatabase()
    {
        self.context.performAndWait()
        {
            self.detailedMapsCache.removeAllObjects()

            for store in self.persistentStoreCoordinator.persistentStores
            {
                _ = try? self.persistentStoreCoordinator.remove(store)
                _ = try? FileManager.default.removeItem(atPath: store.url!.path)
            }
            
            MMTDatabase.instance = MMTDatabase()
        }
    }
    
    // MARK: Helper methods    
    
    fileprivate lazy var applicationDocumentsDirectory: URL =
    {
        let path = FileManager.SearchPathDirectory.documentDirectory
        let domain = FileManager.SearchPathDomainMask.userDomainMask
        
        return FileManager.default.urls(for: path, in: domain).last!
    }()
    
    fileprivate func reportFatalError(_ error: NSError?)
    {
        NSLog("CoreData fatal error: \(String(describing: error))")
        abort()
    }
}
