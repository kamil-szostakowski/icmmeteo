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
    let commentFetchError = "Nie udało się pobrać komentarza, spróbuj ponownie później."
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIDevice.shared.orientation = .portrait
        
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
    func test_displayMeteorogram()
    {
        app.tables.cells["Białystok, Podlaskie"].tap()
        verifyFailureAlert(app.alerts.element(boundBy: 0), meteorogramFetchError)
    }        
    
    func test_selectLocationOnMap()
    {
        app.otherElements["cities-search"].tap()
        app.otherElements["cities-search"].typeText("aaa")
        
        sleep(3)
        app.tables.cells["find-city-on-map"].tap()
        
        let
        map = app.maps.element(boundBy: 0)        
        map.press(forDuration: 1.3)
        
        app.navigationBars["select-location-screen"].buttons["show"].tap()

        verifyFailureAlert(app.alerts.element(boundBy: 0), locationResolveError)
    }

    func test_displayDetailedMapPreview()
    {
        app.tabBars.buttons["Mapy"].tap()
        app.tables.cells.staticTexts["Opady atmosferyczne"].tap()

        sleep(5)
        verifyFailureAlert(app.alerts.element(boundBy: 0), meteorogramFetchError)
    }
    
    func test_forecasterCommentUnavailable()
    {
        app.tabBars.buttons["Komentarz"].tap()        
        
        sleep(5)
        let content = app.textViews["comment-content"].value as? String
        
        verifyFailureAlert(app.alerts.element(boundBy: 0), commentFetchError)
        XCTAssertEqual(content!.count, 0)
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
