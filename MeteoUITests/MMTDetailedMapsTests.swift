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

        XCUIDevice.shared().orientation = .portrait
        
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
    
    func test_detailedMapsCountForUmModel()
    {
        displayDetailedMapsListForModel("UM")
        
        XCTAssertTrue(app.navigationBars["detailed-maps-list-screen"].exists)
        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, 16);
    }
    
    func test_detailedMapsCountForCoampsModel()
    {
        displayDetailedMapsListForModel("COAMPS")
        
        XCTAssertTrue(app.navigationBars["detailed-maps-list-screen"].exists)
        XCTAssertEqual(app.tables.element(boundBy: 0).cells.count, 11);
    }
    
    // MARK: Helper methods
    
    private func displayDetailedMapsListForModel(_ model: String)
    {
        app.tabBars.buttons["Mapy"].tap()
        app.buttons[model].tap()
    }
    
}
