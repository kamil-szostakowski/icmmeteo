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
    static var onceToken: Int = 0

    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIDevice.shared().orientation = .portrait        
        
        app = XCUIApplication()
        app.launchArguments = ["CLEANUP_DB"]
        
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
    
    func test_OpenAndCloseOfPreview()
    {
        app.tabBars.buttons["Model WAM"].tap()
        app.cells["AvgTidePeriod +3"].tap()
        app.toolbars.buttons["Zatrzymaj"].tap()        
    }
    
    func test_DisplayingFirstMeteorogram()
    {
        app.collectionViews.cells["TideHeight +6"].tap()
        
        let nextBtn = app.toolbars.buttons.matching(identifier: "NextButton").element
        let prevBtn = app.toolbars.buttons.matching(identifier: "PrevButton").element
        
        prevBtn.tap()
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: nextBtn){
            
            XCTAssertTrue(nextBtn.isEnabled)
            XCTAssertFalse(prevBtn.isEnabled)
            return true
        }
        
        waitForExpectations(timeout: 7, handler: nil)
    }
    
    func test_DisplayingNextMeteorograms()
    {
        app.collectionViews.cells["TideHeight +6"].tap()
        
        let
        nextBtn = app.toolbars.buttons.matching(identifier: "NextButton").element
        nextBtn.tap()
        
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: nextBtn){
            
            XCTAssertTrue(self.app.staticTexts["MomentDetails"].label.contains("+009h"))
            return true
        }
        
        waitForExpectations(timeout: 7, handler: nil)
    }
    
    func test_DisplayPreviousMeteorogram()
    {
        app.collectionViews.element.swipeLeft()        
        app.collectionViews.cells["TideHeight +9"].tap()
        
        let
        prevBtn = app.toolbars.buttons.matching(identifier: "PrevButton").element
        prevBtn.tap()
        
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: prevBtn){
            
            XCTAssertTrue(self.app.staticTexts["MomentDetails"].label.contains("+006h"))
            return true
        }
        
        waitForExpectations(timeout: 7, handler: nil)
    }
    
    func test_RestoreDefaultZoom()
    {
        app.tabBars.buttons["Model WAM"].tap()
        app.cells["TideHeight +3"].tap()
        app.images["TideHeight"].swipeLeft()
        app.images["TideHeight"].doubleTap()
    }

    // TODO: Add test which verifies displaying of the last meteorogram.
    
    // MARK: Helper methods
    
    fileprivate func goToWamModel()
    {
        app.tabBars.buttons["Model WAM"].tap()
    }
    
    fileprivate func setupSettingsForTest()
    {
        app.navigationBars.buttons["Utwórz"].tap()
        
        app.tables.children(matching: .other).matching(identifier: "WamSettingsHeader").element(boundBy: 0).buttons.element.tap()
        app.tables.cells["WamSettingsMoment: t0 +3h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +6h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +9h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +12h"].tap()
        app.tables.cells["WamSettingsMoment: t0 +84h"].tap()
        
        app.navigationBars["Ustawienia WAM"].buttons["Pokaż"].tap()
    }
}
