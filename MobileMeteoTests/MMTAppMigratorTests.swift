//
//  MMTMigratorTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 16.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest
import MeteoModel
@testable import MobileMeteo

class MMTAppMigratorTests: XCTestCase
{
    // MARK: Properties
    var appMigrator: MMTAppMigrator!
    
    var stubMigrators: [StubMigrator] {
        return appMigrator.migrators
            .filter { $0 is StubMigrator }
            .map { $0 as! StubMigrator }
    }
    
    override func setUp()
    {
        super.setUp()
        
        UserDefaults.standard.cleanup()
        
        appMigrator = try? MMTAppMigrator(migrators: [
            StubMigrator(sequenceNumber: 1),
            StubMigrator(sequenceNumber: 2),
            StubMigrator(sequenceNumber: 3)
        ])
    }
    
    // MARK: Test methods
    func testInvalidMigrationChain_DuplicatedMigrators()
    {
        let migrators = [StubMigrator(sequenceNumber: 1), StubMigrator(sequenceNumber: 1)]
        XCTAssertThrowsError(try MMTAppMigrator(migrators: migrators))
    }
    
    func testInvalidMigrationChain_WrongStartingPoint()
    {
        let migrators = [StubMigrator(sequenceNumber: 2), StubMigrator(sequenceNumber: 3)]
        XCTAssertThrowsError(try MMTAppMigrator(migrators: migrators))
    }
    
    func testInvalidMigrationChain_IncompleteChain()
    {
        let migrators = [StubMigrator(sequenceNumber: 1), StubMigrator(sequenceNumber: 3)]
        XCTAssertThrowsError(try MMTAppMigrator(migrators: migrators))
    }
    
    func testInvalidMigrationChain_Empty()
    {
        XCTAssertThrowsError(try MMTAppMigrator(migrators: []))
    }
    
    func testInitialization()
    {
        XCTAssertEqual(appMigrator.migrators.map { $0.sequenceNumber }, [1,2,3])
    }
    
    func testEmptyMigration()
    {
        try! appMigrator.migrate(from: 3)

        XCTAssertEqual(stubMigrators[0].migrated, false)
        XCTAssertEqual(stubMigrators[1].migrated, false)
        XCTAssertEqual(stubMigrators[2].migrated, false)
        
        XCTAssertEqual(UserDefaults.standard.sequenceNumber, 0)
    }
    
    func testFullMigration()
    {
        try! appMigrator.migrate(from: 0)
        
        XCTAssertEqual(stubMigrators[0].migrated, true)
        XCTAssertEqual(stubMigrators[1].migrated, true)
        XCTAssertEqual(stubMigrators[2].migrated, true)
        
        XCTAssertEqual(UserDefaults.standard.sequenceNumber, 3)
    }
    
    func testPartialMigration()
    {
        try! appMigrator.migrate(from: 2)
        
        XCTAssertEqual(stubMigrators[0].migrated, false)
        XCTAssertEqual(stubMigrators[1].migrated, false)
        XCTAssertEqual(stubMigrators[2].migrated, true)
        
        XCTAssertEqual(UserDefaults.standard.sequenceNumber, 3)
    }
    
    func testMigrationFailure()
    {
        class ThrowingMigrator : MMTVersionMigrator {
            var sequenceNumber: UInt = 1
            func migrate() throws {
                throw MMTError.migrationFailure
            }
        }
        
        XCTAssertThrowsError(try MMTAppMigrator(migrators: [ThrowingMigrator()]).migrate(from: 0))
    }
}
