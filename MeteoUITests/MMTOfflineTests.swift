//
//  MMTOfflineTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 02.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTOfflineTests: XCTestCase
{
    var app: XCUIApplication!
    let meteorogramFetchError = "Nie udało się pobrać meteorogramu. Spróbuj ponownie później."
    let locationResolveError = "Nie udało się odnaleźć szczegółów lokalizacji. Wybierz inną lokalizację lub spróbuj ponownie później."
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIDevice.shared().orientation = .portrait
        
        app = XCUIApplication()
        app.launchArguments = ["CLEANUP_DB", "SIMULATED_OFFLINE_MODE"]
        app.launch()
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func test_displayUmMeteorogram()
    {
        app.tables.cells["Białystok, Podlaskie"].tap()

        verifyFailureAlert(app.alerts.element(boundBy: 0), meteorogramFetchError)
    }
    
    func test_displayCoampsMeteorogram()
    {
        app.tabBars.buttons["Model COAMPS"].tap()
        app.tables.cells["Białystok, Podlaskie"].tap()
        
        verifyFailureAlert(app.alerts.element(boundBy: 0), meteorogramFetchError)
    }
    
    func test_displayWamMomentPreview()
    {
        app.tabBars.buttons["Model WAM"].tap()
        app.collectionViews.cells["TideHeight +3"].tap()
        
        verifyFailureAlert(app.alerts.element(boundBy: 0), meteorogramFetchError)
    }
    
    func test_selectLocationOnMap()
    {
        app.searchFields["szukaj miasta"].tap()
        app.searchFields["szukaj miasta"].typeText("aaa")
        
        sleep(5)
        app.tables.staticTexts["Wskaż lokalizację na mapie"].tap()
        
        let
        map = app.maps.element(boundBy: 0)
        map.pinch(withScale: 4, velocity: 4)
        map.press(forDuration: 1.3)
        
        app.navigationBars["Wybierz lokalizację"].buttons["Pokaż"].tap()

        verifyFailureAlert(app.alerts.element(boundBy: 0), locationResolveError)
    }

    func test_displayDetailedMapPreview()
    {
        app.tabBars.buttons["Mapy"].tap()
        app.tables.cells.staticTexts["Opad"].tap()

        sleep(5)

        verifyFailureAlert(app.alerts.element(boundBy: 0), meteorogramFetchError)
    }
    
    // MARK: Helper methods
    
    private func verifyFailureAlert(_ alert: XCUIElement, _ message: String)
    {
        let errorMsg = alert.staticTexts.element(boundBy: 0).label
        
        alert.buttons["zamknij"].tap()
        
        XCTAssertEqual(message, errorMsg)
        XCTAssertFalse(alert.exists)
    }
}
