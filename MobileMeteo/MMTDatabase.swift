//
//  MMTMeteoDatabase.swift
//  MobileMeteo
//
//  Created by szostakowskik on 03.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation
import MeteoModel
import CoreData

public class MMTDatabase
{
    // MARK: Properties
    public static private(set) var instance = MMTDatabase()
    
    public var meteorogramsCache = NSCache<NSString, UIImage>()
    
    // MARK: CoreData stack
    lazy var model: NSManagedObjectModel =
        {
            let bundle = Bundle(for: MMTMeteorogramStore.self)
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
}

extension MMTDatabase: MMTEntityFactory
{
    public func createCity() -> MMTCityProt
    {
        let entityDescription = NSEntityDescription.entity(forEntityName: "MMTCity", in: context)!
        return MMTCity(entity: entityDescription, insertInto: nil)
    }
}

