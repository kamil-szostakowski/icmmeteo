//
//  MMTWamCategoryPreviewTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 25.11.2015.
//  Copyright © 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTWamCategoryPreviewTests: XCTestCase
{
    var app: XCUIApplication!
    static var onceToken: dispatch_once_t = 0
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIDevice.sharedDevice().orientation = .Portrait        
        
        app = XCUIApplication()

        dispatch_once(&MMTWamCategoryPreviewTests.onceToken){
            self.app.launchArguments = ["CLEANUP_DB"]
        }
        
        app.launch()
        goToWamModel()
        setupSettingsForTest()
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func test01_OpenAndCloseOfPreview()
    {
        app.tabBars.buttons["Model WAM"].tap()
        app.cells["AvgTidePeriod +3"].tap()
        app.toolbars.buttons["Zatrzymaj"].tap()        
    }
    
    func test02_DisplayingFirstMeteorogram()
    {
        app.collectionViews.cells["TideHeight +6"].tap()
        
        let nextBtn = app.toolbars.buttons.matchingIdentifier("NextButton").element
        let prevBtn = app.toolbars.buttons.matchingIdentifier("PrevButton").element
        
        prevBtn.tap()
        expectationForPredicate(NSPredicate(format: "enabled == true"), evaluatedWithObject: nextBtn){
            
            XCTAssertTrue(nextBtn.enabled)
            XCTAssertFalse(prevBtn.enabled)
            return true
        }
        
        waitForExpectationsWithTimeout(7, handler: nil)
    }
    
    func test03_DisplayingNextMeteorograms()
    {
        app.collectionViews.cells["TideHeight +6"].tap()
        
        let
        nextBtn = app.toolbars.buttons.matchingIdentifier("NextButton").element
        nextBtn.tap()
        
        expectationForPredicate(NSPredicate(format: "enabled == true"), evaluatedWithObject: nextBtn){
            
            XCTAssertTrue(self.app.staticTexts.elementBoundByIndex(1).label.containsString("+009h"))
            return true
        }
        
        waitForExpectationsWithTimeout(7, handler: nil)
    }
    
    func test04_DisplayPreviousMeteorogram()
    {
        app.collectionViews.element.swipeLeft()        
        app.collectionViews.cells["TideHeight +9"].tap()
        
        let
        prevBtn = app.toolbars.buttons.matchingIdentifier("PrevButton").element
        prevBtn.tap()
        
        expectationForPredicate(NSPredicate(format: "enabled == true"), evaluatedWithObject: prevBtn){
            
            XCTAssertTrue(self.app.staticTexts.elementBoundByIndex(1).label.containsString("+006h"))
            return true
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func test05_RestoreDefaultZoom()
    {
        app.tabBars.buttons["Model WAM"].tap()
        app.cells["TideHeight +3"].tap()
        app.images["TideHeight"].swipeLeft()
        app.images["TideHeight"].doubleTap()
    }

    // TODO: Add test which verifies displaying of the last meteorogram.
    
    // MARK: Helper methods
    
    private func goToWamModel()
    {
        app.tabBars.buttons["Model WAM"].tap()
    }
    
    private func setupSettingsForTest()
    {
        app.navigationBars.buttons["Utwórz"].tap()
        
        app.tables.childrenMatchingType(.Other).matchingIdentifier("WamSettingsHeader").elementBoundByIndex(0).buttons.element.tap()
        app.tables.cells["WamSettingsMoment: t0 +3h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +6h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +9h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +12h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +84h"].tap()
        
        app.navigationBars["Ustawienia WAM"].buttons["Pokaż"].tap()
    }
}