//
//  MMTDetailedMapPreviewTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 22/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest

class MMTDetailedMapPreviewTests: XCTestCase
{
    // MARK: Properties

    var app: XCUIApplication!
    let fetchWaitTime = TimeInterval(30)

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
    
    func test_DisplayMapPreviewForModelUm()
    {
        let mapTitle = "Opad"        
        displayPreview(for: mapTitle, model: "UM")

        let actualMapTitle = app.staticTexts["DetailedMapTitle"].label
        XCTAssertEqual(mapTitle, actualMapTitle)
    }

    func test_DisplayMapPreviewForModelCoamps()
    {
        let mapTitle = "Wiatr przyziemny"
        displayPreview(for: mapTitle, model: "COAMPS")

        let actualMapTitle = app.staticTexts["DetailedMapTitle"].label
        XCTAssertEqual(mapTitle, actualMapTitle)
    }

    func test_HideActivityIndicatorAfterDataFetch()
    {
        displayPreview(for: "Chmury bardzo niskie", model: "UM")

        let activityIndicator = app.activityIndicators.element(boundBy: 0)
        let slider = app.sliders.element(boundBy: 0)

        XCTAssertTrue(activityIndicator.isHittable)
        XCTAssertFalse(slider.isEnabled)

        expectation(for: NSPredicate(format: "isHittable == false"), evaluatedWith: activityIndicator){

            XCTAssertTrue(slider.isEnabled)
            return true
        }

        waitForExpectations(timeout: fetchWaitTime, handler: nil)
    }

    func test_MoveSlider()
    {
        let mapTitle = "Chmury bardzo niskie"

        displayPreview(for: mapTitle, model: "UM")

        let activityIndicator = app.activityIndicators.element(boundBy: 0)
        let actualMapTitle = app.staticTexts["DetailedMapTitle"].label
        let initialMomentLabel = app.staticTexts["DetailedMapMoment"].label

        expectation(for: NSPredicate(format: "isHittable == false"), evaluatedWith: activityIndicator){

            self.app.sliders.element(boundBy: 0).adjust(toNormalizedSliderPosition: 0.3)

            XCTAssertNotEqual(initialMomentLabel, self.app.staticTexts["DetailedMapMoment"].label)
            XCTAssertEqual(mapTitle, actualMapTitle)
            return true
        }

        waitForExpectations(timeout: fetchWaitTime, handler: nil)
    }

    func test_ScrollViewActions()
    {
        displayPreview(for: "Chmury bardzo niskie", model: "UM")

        let activityIndicator = app.activityIndicators.element(boundBy: 0)
        let mapImage = app.scrollViews.images.element(boundBy: 0)
        let scrollView = app.scrollViews.element(boundBy: 0)

        let initialImageSize = mapImage.frame.size

        expectation(for: NSPredicate(format: "isHittable == false"), evaluatedWith: activityIndicator){

            scrollView.pinch(withScale: 2, velocity: 5)
            XCTAssertNotEqual(initialImageSize, mapImage.frame.size)

            mapImage.doubleTap()
            XCTAssertEqual(initialImageSize, mapImage.frame.size)
            return true
        }

        waitForExpectations(timeout: fetchWaitTime, handler: nil)
    }

    // MARK: Helper methods

    private func displayPreview(for map: String, model: String)
    {
        app.tabBars.buttons["Mapy"].tap()
        app.buttons[model].tap()
        app.tables.cells.staticTexts[map].tap()
    }
    
}
