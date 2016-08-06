//
//  MMTDetailedMapsTests.swift
//  MobileMeteo
//
//  Created by Kamil on 31.07.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTDetailedMapsTests: XCTestCase
{    
    var app: XCUIApplication!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false

        XCUIDevice.sharedDevice().orientation = .Portrait
        
        app = XCUIApplication()
        app.launchArguments = ["CLEANUP_DB"]
        app.launch()
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func test01_displayDetiledMapsList()
    {
        displayDetailedMapsListForModel("UM")
        XCTAssertTrue(app.navigationBars["Mapy szczegółowe"].exists)
        
        app.navigationBars["Mapy szczegółowe"].buttons["Zatrzymaj"].tap()
        XCTAssertFalse(app.navigationBars["Mapy szczegółowe"].exists)
    }
    
    func test02_detailedMapsCountForUmModel()
    {
        displayDetailedMapsListForModel("UM")
        
        XCTAssertTrue(app.navigationBars["Mapy szczegółowe"].exists)
        XCTAssertEqual(app.tables.elementBoundByIndex(0).cells.count, 16);
    }
    
    func test03_detailedMapsCountForCoampsModel()
    {
        displayDetailedMapsListForModel("COAMPS")
        
        XCTAssertTrue(app.navigationBars["Mapy szczegółowe"].exists)
        XCTAssertEqual(app.tables.elementBoundByIndex(0).cells.count, 11);
    }
    
    // MARK: Helper methods
    
    private func displayDetailedMapsListForModel(model: String)
    {
        app.tabBars.buttons["Model \(model)"].tap()
        app.tables.cells["Mapy szczegółowe"].tap()
    }
    
}
