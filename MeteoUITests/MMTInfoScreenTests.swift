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
    
    func test01_displayMailComposeScreen()
    {
        app.tabBars.buttons["Źródło"].tap()
        app.buttons["napisz do nas"].tap()
    }
}
