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
    
    func test01_ZoomingToDefaultScale()
    {
        app.tables.cells["Białystok, Podlaskie"].tap()
        
        let
        element = app.scrollViews.elementBoundByIndex(0)
        element.swipeLeft()
        element.doubleTap()
        
        app.navigationBars["Białystok"].buttons["Zatrzymaj"].tap()
    }
}
