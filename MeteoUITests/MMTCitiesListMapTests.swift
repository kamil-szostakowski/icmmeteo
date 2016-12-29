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
        searchField = app.tables.searchFields["szukaj miasta"]
        searchField.tap()
        searchField.typeText("aaa")

        sleep(3)
        app.tables.cells[locationNotFound].tap()

        let
        map = app.maps.element(boundBy: 0)
        map.pinch(withScale: 4, velocity: 4)
        map.press(forDuration: 1.3)

        app.navigationBars["Wybierz lokalizację"].buttons["Pokaż"].tap()

        let navBar = app.navigationBars.element(boundBy: 0)

        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: navBar.buttons["star outline"]) {

            navBar.buttons["star outline"].tap()
            navBar.buttons["Zatrzymaj"].tap()

            XCTAssertEqual(self.detailedMaps, self.app.tables.cells.element(boundBy: 0).label)
            self.XCTCheckHeader(self.headerFavourites)
            self.XCTCheckHeader(self.headerCapitals)

            return true
        }

        waitForExpectations(timeout: 10){ _ in

            self.removeFromFavourites(self.app.tables.cells.element(boundBy: 2).label)

            /* --- Assertions -- */

            XCTAssertEqual(self.detailedMaps, self.app.tables.cells.element(boundBy: 0).label)
            XCTAssertEqual(self.bialystok, self.app.tables.cells.element(boundBy: 2).label)
            self.XCTCheckHeader(self.headerCapitals)
        }
    }
}
