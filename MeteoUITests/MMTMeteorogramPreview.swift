//
//  MMTCitiesListSearchTests.swift
//  MobileMeteo
//
//  Created by Kamil on 21.11.2015.
//  Copyright © 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTMeteorogramPreviewTests: XCTestCase
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
        MMTAssertMeteorogramNotLoaded(in: app)
        waitForIndicator()
        MMTAssertMeteorogramLoaded(in: app)
    }
    
    func test_MeteorogramLegendVisibilityInPortrait()
    {
        waitForIndicator()
        XCTAssertFalse(isElementVisible(app.images["legend-loaded"]))
    }
    
    func test_SwitchToCoampsModel()
    {
        MMTAssertMeteorogramNotLoaded(in: app)
        waitForIndicator()
        MMTAssertMeteorogramLoaded(in: app)
        
        app.segmentedControls.buttons["COAMPS (84h)"].tap()
        
        MMTAssertMeteorogramNotLoaded(in: app)
        waitForIndicator()
        MMTAssertMeteorogramLoaded(in: app)
    }
    
    func test_ContentVisibilityInLandscape()
    {
        waitForIndicator()
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)
        
        XCTAssertTrue(isElementVisible(app.images["meteorogram-loaded"]))
        XCTAssertTrue(isElementVisible(app.images["legend-loaded"]))
    }
    
    // MARK: Helper methods
    private func isElementVisible(_ element: XCUIElement) -> Bool
    {
        let window = app.windows.element(boundBy: 0)
        return window.frame.intersects(element.frame)
    }
    
    private func waitForIndicator()
    {
        let predicate = NSPredicate(format: "exists == false")
        let activityIndicator = app.otherElements["activity-indicator"]
        let expect = expectation(for: predicate, evaluatedWith: activityIndicator, handler: nil)
        
        if XCTWaiter.wait(for: [expect], timeout: 5) != .completed {
            XCTFail("Meteorogram failed to load")
        }
    }
}

// MARK: Helper asserts
fileprivate func MMTAssertMeteorogramLoaded(in app: XCUIApplication, file: StaticString = #file, line: UInt = #line)
{
    let indicator = app.otherElements["activity-indicator"]
    let emptyMeteorogram = app.images["meteorogram"]
    let loadedMeteorogram = app.images["meteorogram-loaded"]
    
    XCTAssertFalse(indicator.exists, "Activity indicator not hidden", file: file, line: line)
    XCTAssertFalse(emptyMeteorogram.exists, "Meteorogram image view is empty", file: file, line: line)
    XCTAssertTrue(loadedMeteorogram.exists, "Meteorogram not loaded", file: file, line: line)
}

fileprivate func MMTAssertMeteorogramNotLoaded(in app: XCUIApplication, file: StaticString = #file, line: UInt = #line)
{
    let indicator = app.otherElements["activity-indicator"]
    let emptyMeteorogram = app.images["meteorogram"]
    let loadedMeteorogram = app.images["meteorogram-loaded"]
    
    XCTAssertTrue(indicator.exists, "Activity indicator not visible")
    XCTAssertTrue(emptyMeteorogram.exists, "Meteorogram image view is not empty")
    XCTAssertFalse(loadedMeteorogram.exists, "Unexpected meteorogram present", file: file, line: line)
}
