//
//  MMTMeteorogramWamTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 25.11.2015.
//  Copyright © 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTMeteorogramWamTests: XCTestCase
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
        
        sleep(1)
        app.tabBars.buttons["Model WAM"].tap()
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func test_DisplayTideHeightMomentPreview()
    {
        app.collectionViews.cells["TideHeight +3"].tap()        
        
        /* --- Assertions -- */
        
        XCTAssertTrue(app.images["TideHeight"].exists)
    }
    
    func test_DisplayAvgTidePeriodMomentPreview()
    {
        app.collectionViews.cells["AvgTidePeriod +3"].tap()
        
        /* --- Assertions -- */
        
        XCTAssertTrue(app.images["AvgTidePeriod"].exists)
    }

    func test_DisplaySpectrumPeakPeriodMomentPreview()
    {
        app.collectionViews.cells["SpectrumPeakPeriod +3"].tap()
        
        /* --- Assertions -- */
        
        XCTAssertTrue(app.images["SpectrumPeakPeriod"].exists)
    }
    
    func test_CategoriesHeadersExistence()
    {
        let headers = app.collectionViews.children(matching: .other).matching(identifier: "MMTWamHeaderView")
        
        /* --- Assertions -- */
        
        XCTAssertEqual("Wysokość fali znacznej i średni kierunek fali", headers.element(boundBy: 0).label)
        XCTAssertEqual("Średni okres fali", headers.element(boundBy: 1).label)
        XCTAssertEqual("Okres piku widma", headers.element(boundBy: 2).label)
    }
}
