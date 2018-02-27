//
//  MMTMigrator.swift
//  MobileMeteo
//
//  Created by szostakowskik on 16.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import Foundation

protocol MMTVersionMigrator
{
    var sequenceNumber: UInt { get }
    
    func migrate() throws
}

class MMTAppMigrator
{
    // MARK: Properties
    private(set) var migrators: [MMTVersionMigrator]
    
    // MARK: Initializers
    init(migrators: [MMTVersionMigrator]) throws
    {
        let sequenceNumbers = migrators.map { $0.sequenceNumber }.sorted()
        
        // Eliminate duplicates
        if sequenceNumbers.count != Set(sequenceNumbers).count {
            throw MMTError.invalidMigrationChain
        }
        
        // Should start with 1
        if sequenceNumbers.first != 1 {
            throw MMTError.invalidMigrationChain
        }
        
        // Should increment by 1
        if sequenceNumbers.reduce(0, +) != (1...sequenceNumbers.count).reduce(0, +) {
            throw MMTError.invalidMigrationChain
        }
        
        self.migrators = migrators.sorted { $0.sequenceNumber < $1.sequenceNumber }
    }
    
    // MARK: Interface methods
    func migrate(from sequenceNumber: UInt) throws
    {
        let designatedMigrators = migrators[Int(sequenceNumber)..<migrators.count]
        
        for migrator in designatedMigrators {
            try migrator.migrate()
            UserDefaults.standard.sequenceNumber = migrator.sequenceNumber
        }
    }
}
