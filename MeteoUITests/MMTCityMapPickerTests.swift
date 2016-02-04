//
//  MMTCityMapPickerTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 03.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTCityMapPickerTests: XCTestCase
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
        
        app.tables.searchFields["szukaj miasta"].tap()
        app.tables.searchFields["szukaj miasta"].typeText("aaa")
        app.tables.staticTexts["Wskaż lokalizację na mapie"].tap()
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func test01_dismissMapPicker()
    {
        XCTAssertTrue(app.navigationBars["Wybierz lokalizację"].exists)
        
        app.navigationBars["Wybierz lokalizację"].buttons["Zatrzymaj"].tap()
        sleep(1)
        XCTAssertFalse(app.navigationBars["Wybierz lokalizację"].exists)
    }
    
    func test02_selectUnsupportedLocation()
    {
        let
        map = app.maps.elementBoundByIndex(0)
        map.pinchWithScale(0.09, velocity: -0.02)
        map.swipeDown()
        map.swipeDown()
        map.pressForDuration(1.3)
        
        app.navigationBars["Wybierz lokalizację"].buttons["Pokaż"].tap()
        
        let alert = app.alerts.elementBoundByIndex(0)
        let errorMsg = alert.staticTexts.elementBoundByIndex(2).label
        
        alert.buttons["zamknij"].tap()
        
        XCTAssertEqual("Wybrana lokacja nie jest obsługiwana.", errorMsg)
        XCTAssertFalse(alert.exists)
    }
}
