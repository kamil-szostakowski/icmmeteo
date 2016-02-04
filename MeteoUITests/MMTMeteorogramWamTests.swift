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
        
        XCUIDevice.sharedDevice().orientation = .Portrait
        
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
    
    func test01_DisplayTideHeightMomentPreview()
    {
        app.collectionViews.cells["TideHeight +3"].tap()
        
        /* --- Assertions -- */
        
        XCTAssertTrue(app.images["TideHeight"].exists)
    }
    
    func test02_DisplayAvgTidePeriodMomentPreview()
    {
        app.collectionViews.cells["AvgTidePeriod +3"].tap()
        
        /* --- Assertions -- */
        
        XCTAssertTrue(app.images["AvgTidePeriod"].exists)
    }

    func test03_DisplaySpectrumPeakPeriodMomentPreview()
    {
        app.collectionViews.cells["SpectrumPeakPeriod +3"].tap()
        
        /* --- Assertions -- */
        
        XCTAssertTrue(app.images["SpectrumPeakPeriod"].exists)
    }
    
    func test04_NumberOfDisplayedMoments()
    {
        app.navigationBars.buttons["Utwórz"].tap()
        app.tables.childrenMatchingType(.Other).matchingIdentifier("WamSettingsHeader").elementBoundByIndex(0).buttons.element.tap()
        
        app.tables.cells["WamSettingsMoment: t0 +3h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +9h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +15h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +21h"].tap()
        
        app.navigationBars["Ustawienia WAM"].buttons["Pokaż"].tap()
        app.collectionViews.element.swipeLeft()
        
        let momentAtIndex = {(index: UInt) in
            return self.app.collectionViews.cells.elementBoundByIndex(index).staticTexts.elementBoundByIndex(1).label
        }
        
        /* --- Assertions -- */
        
        XCTAssertEqual(4, app.collectionViews.cells.count/3)
        XCTAssertEqual("t0 +003h", momentAtIndex(0))
        XCTAssertEqual("t0 +009h", momentAtIndex(5))
        XCTAssertEqual("t0 +015h", momentAtIndex(10))
        XCTAssertEqual("t0 +021h", momentAtIndex(7))
    }
    
    func test05_CategoriesHeadersExistence()
    {
        let headers = app.collectionViews.childrenMatchingType(.Other).matchingIdentifier("MMTWamHeaderView")
        
        /* --- Assertions -- */
        
        XCTAssertEqual("Wysokość fali znacznej i średni kierunek fali", headers.elementBoundByIndex(0).label)
        XCTAssertEqual("Średni okres fali", headers.elementBoundByIndex(1).label)
        XCTAssertEqual("Okres piku widma", headers.elementBoundByIndex(2).label)
    }
}