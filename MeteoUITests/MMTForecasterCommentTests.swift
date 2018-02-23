//
//  MMTForecasterCommentTests.swift
//  MobileMeteoTests
//
//  Created by szostakowskik on 23.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import XCTest

class MMTForecasterCommentTests: XCTestCase
{
    // MARK: Properties
    var app: XCUIApplication!
    let fetchWaitTime = TimeInterval(30)
    
    // MARK: Setup methods
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        
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
    func test_ForecasterCommentAvailable()
    {
        app.tabBars.buttons["Komentarz"].tap()
        sleep(3)
        
        let content = app.textViews["comment-content"].value as? String
        XCTAssertGreaterThan(content!.count, 0)
    }    
}
