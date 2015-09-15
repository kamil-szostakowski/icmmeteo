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
    static let instance = MMTDatabase()
    
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
        
        var error: NSError?
        if coordinator.addPersistentStoreWithType(type, configuration: nil, URL: storeURL, options: nil, error: &error) == nil
        {
            self.reportFatalError(error)
        }
        
        return coordinator
    }()
    
    lazy var context: NSManagedObjectContext =
    {
        let context = NSManagedObjectContext()
        context.persistentStoreCoordinator = self.persistentStoreCoordinator

        return context
    }()
    
    func saveContext()
    {
        var error: NSError?
        if context.hasChanges && !context.save(&error) {
            reportFatalError(error)
        }
    }    
    
    // MARK: Helper methods    
    
    private lazy var applicationDocumentsDirectory: NSURL =
    {
        let path = NSSearchPathDirectory.DocumentDirectory
        let domain = NSSearchPathDomainMask.UserDomainMask
        
        return NSFileManager.defaultManager().URLsForDirectory(path, inDomains: domain).last as! NSURL
    }()
    
    private func reportFatalError(error: NSError?)
    {
        NSLog("CoreData fatal error: \(error)")
        abort()
    }
}