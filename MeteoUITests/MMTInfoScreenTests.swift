//
//  MMTInfoScreenTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 03.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTInfoScreenTests: XCTestCase
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
        app.launchArguments = ["SKIP_ONBOARDING"]
        app.launch()
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: Test methods
    func test_displayMailComposeScreen()
    {
        app.tabBars.buttons.element(boundBy: 3).tap()
        app.scrollViews.element.swipeUp()
        app.buttons["feedback"].tap()
    }
    
    func test_displayOnboardingScreen()
    {
        // Open onboarding screen
        app.tabBars.buttons.element(boundBy: 3).tap()
        app.scrollViews.element.swipeUp()
        app.buttons["onboarding"].tap()
        
        // Step through all the screens
        app.scrollViews.element.swipeLeft()
        app.scrollViews.element.swipeLeft()
        app.scrollViews.element.swipeLeft()
        
        // Close the screen
        app.buttons["close"].tap()
    }
}
