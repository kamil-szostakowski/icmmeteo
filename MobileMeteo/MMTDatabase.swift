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
    static private(set) var instance = MMTDatabase()
    
    // MARK: CoreData stack
    
    lazy var model: NSManagedObjectModel =
    {
        let modelURL = NSBundle.mainBundle().URLForResource("Mobile_Meteo", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator =
    {
        let type = NSSQLiteStoreType
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Mobile_Meteo.sqlite")
        
        do { try coordinator.addPersistentStoreWithType(type, configuration: nil, URL: storeURL, options: nil) }
        
        catch let error as NSError {
            self.reportFatalError(error)
        }
        
        return coordinator
    }()
    
    lazy var context: NSManagedObjectContext =
    {
        let
        context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator

        return context
    }()
    
    func saveContext()
    {
        if context.hasChanges
        {
            do { try context.save() }
                
            catch let error as NSError {
                reportFatalError(error)
            }
        }        
    }
    
    func flushDatabase()
    {
        self.context.performBlockAndWait()
        {
            for store in self.persistentStoreCoordinator.persistentStores
            {
                _ = try? self.persistentStoreCoordinator.removePersistentStore(store)
                _ = try? NSFileManager.defaultManager().removeItemAtPath(store.URL!.path!)
            }
            
            MMTDatabase.instance = MMTDatabase()
        }
    }
    
    // MARK: Helper methods    
    
    private lazy var applicationDocumentsDirectory: NSURL =
    {
        let path = NSSearchPathDirectory.DocumentDirectory
        let domain = NSSearchPathDomainMask.UserDomainMask
        
        return NSFileManager.defaultManager().URLsForDirectory(path, inDomains: domain).last!
    }()
    
    private func reportFatalError(error: NSError?)
    {
        NSLog("CoreData fatal error: \(error)")
        abort()
    }
}