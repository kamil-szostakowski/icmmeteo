//
//  MMTCitiesListSearchTests.swift
//  MobileMeteo
//
//  Created by Kamil on 21.11.2015.
//  Copyright © 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTMeteorogramPreview: XCTestCase
{
    var app: XCUIApplication!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIDevice.shared.orientation = .portrait
        
        app = XCUIApplication()
        app.launchArguments = ["CLEANUP_DB"]
        app.launch()
        
        app.tabBars.buttons["Model COAMPS"].tap()
        sleep(1)
        app.tables.cells["Białystok, Podlaskie"].tap()        
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func test_ContentVisibilityInPortrait()
    {
        XCTAssertTrue(isElementVisible(app.images["meteorogram"]))
        XCTAssertFalse(isElementVisible(app.images["legend"]))
    }
    
    func test_ZoomingToDefaultScale()
    {
        let
        element = app.scrollViews.element(boundBy: 0)
        element.swipeLeft()
        element.doubleTap()
        
        app.navigationBars["meteorogram-screen"].buttons["close"].tap()
    }
    
    func test_ContentVisibilityInLandscape()
    {
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)
        
        XCTAssertTrue(isElementVisible(app.images["meteorogram"]))
        XCTAssertTrue(isElementVisible(app.images["legend"]))
    }
    
    // MARK: Helper methods
    
    private func isElementVisible(_ element: XCUIElement) -> Bool
    {
        let window = app.windows.element(boundBy: 0)
        return window.frame.intersects(element.frame)
    }
}
