//
//  MMTWamSettingsTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 26.11.2015.
//  Copyright © 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTWamSettingsTests: XCTestCase
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
        
        app.tabBars.buttons["Model WAM"].tap()
        sleep(1)
        app.navigationBars.buttons["Utwórz"].tap()
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func test01_DeselectingGroupOfMoments()
    {
        let header = headerAtIndex(0)
        let subitems = subitemsForHeader(header)
        
        XCTAssertEqual("usuń zaznaczenie", header.buttons.element.label)
        
        for index in 0..<subitems.count {
            XCTAssertTrue(subitems.element(boundBy: index).isSelected)
        }
        
        header.buttons.element.tap()
        
        XCTAssertEqual("wybierz", header.buttons.element.label)
        
        for index in 0..<subitems.count {
            XCTAssertFalse(subitems.element(boundBy: index).isSelected)
        }
    }
    
    func test02_DeselectingHeaderByDeselectingItem()
    {
        let headerButton = headerAtIndex(0).buttons.element
        
        XCTAssertEqual("usuń zaznaczenie", headerButton.label)
        
        app.tables.cells.element(boundBy: 0).tap()
        
        XCTAssertEqual("wybierz", headerButton.label)
    }
    
    func test03_SelectingHeaderBySelectingAllOfSubitems()
    {
        let header = headerAtIndex(0)
        let subitems = subitemsForHeader(header)
        
        XCTAssertEqual("usuń zaznaczenie", header.buttons.element.label)
        
        header.buttons.element.tap()
        
        XCTAssertEqual("wybierz", header.buttons.element.label)
        
        for index in 0..<subitems.count {
            subitems.element(boundBy: index).tap()
        }
        
        XCTAssertEqual("usuń zaznaczenie", header.buttons.element.label)
    }
    
    func test04_SelectingGroupOfMoments()
    {
        let header = headerAtIndex(1)
        let subitems = subitemsForHeader(header)
        
        XCTAssertEqual("wybierz", header.buttons.element.label)
        
        for index in 0..<subitems.count {
            XCTAssertFalse(subitems.element(boundBy: index).isSelected)
        }
        
        header.buttons.element.tap()
        
        XCTAssertEqual("usuń zaznaczenie", header.buttons.element.label)
        
        for index in 0..<subitems.count {
            XCTAssertTrue(subitems.element(boundBy: index).isSelected)
        }
    }
    
    func test05_TestShowButtonAppearance()
    {
        let header = headerAtIndex(0)
        let subitems = subitemsForHeader(header)
        let showButton = app.navigationBars["Ustawienia WAM"].buttons["Pokaż"]
        
        header.buttons.element.tap()
        XCTAssertFalse(showButton.isEnabled)
        
        subitems.element(boundBy: 0).tap()
        subitems.element(boundBy: 1).tap()
        XCTAssertFalse(showButton.isEnabled)
        
        subitems.element(boundBy: 2).tap()
        XCTAssertTrue(showButton.isEnabled)
    }
    
    // MARK: Helper methods
    
    fileprivate func headerAtIndex(_ index: UInt) -> XCUIElement
    {
        return app.tables.children(matching: .other).matching(identifier: "WamSettingsHeader").element(boundBy: index)
    }
    
    fileprivate func subitemsForHeader(_ header: XCUIElement) -> XCUIElementQuery
    {
        return app.tables.cells.matching(NSPredicate(format: "label CONTAINS[cd] %@", header.staticTexts.element.label))
    }
}
