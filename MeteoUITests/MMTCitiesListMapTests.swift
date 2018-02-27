//
//  MMTCitiesListMapTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest

class MMTCitiesListMapTests: MMTCitiesListTestCase
{    
    func test_AddingAndRemovingCityPointedOnMapFromFavourites()
    {
        let
        searchField = app.otherElements["cities-search"]
        searchField.tap()
        searchField.typeText("aaa")

        sleep(3)
        app.tables.cells["find-city-on-map"].tap()

        let
        map = app.maps.element(boundBy: 0)
        map.press(forDuration: 1.5)

        app.navigationBars["select-location-screen"].buttons["show"].tap()
        let navBar = app.navigationBars["meteorogram-screen"]
        
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: navBar.buttons["toggle-favourite"]) {

            navBar.buttons["toggle-favourite"].tap()
            navBar.buttons["close"].tap()
            
            self.XCTCheckHeader(self.headerFavourites)
            self.XCTCheckHeader(self.headerCapitals)

            return true
        }

        waitForExpectations(timeout: 10){ _ in

            self.removeFromFavourites(self.app.tables.cells.element(boundBy: Int(0 + self.tableOffset)).label)

            /* --- Assertions -- */
            
            XCTAssertEqual(self.bialystok, self.app.tables.cells.element(boundBy: Int(0 + self.tableOffset)).label)
            self.XCTCheckHeader(self.headerCapitals)
        }
    }
    
    func test_dismissMapPicker()
    {
        app.otherElements["cities-search"].tap()
        app.otherElements["cities-search"].typeText("aaa")
        app.tables.cells["find-city-on-map"].tap()
        
        let navBar = app.navigationBars["select-location-screen"]
        
        XCTAssertTrue(navBar.exists)
        navBar.buttons["close"].tap()
        sleep(1)
        XCTAssertFalse(navBar.exists)
    }
}
