//
//  MMTDatabase.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 15.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import CoreData

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

