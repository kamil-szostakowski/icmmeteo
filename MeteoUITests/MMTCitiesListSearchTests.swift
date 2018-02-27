//
//  MMTCitiesListSearchTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest

class MMTCitiesListSearchTests: MMTCitiesListTestCase
{
    func test_AddingAndRemovingFoundCityFromFavourites()
    {
        /* --- Adding cities to favourites -- */

        let
        searchField = app.otherElements["cities-search"]
        searchField.tap()
        searchField.typeText("Iława")

        sleep(3)

        XCTAssertEqual(ilawa, app.tables.cells.element(boundBy: Int(0 + tableOffset)).label)
        XCTAssertEqual(locationNotFound, app.tables.cells.element(boundBy: Int(1 + tableOffset)).label)

        addToFavourites(ilawa)

        /* --- Assertions -- */
        
        XCTCheckHeader(headerFavourites)
        XCTAssertEqual(ilawa, app.tables.cells.element(boundBy: Int(0 + tableOffset)).label)
        XCTCheckHeader(headerCapitals)

        /* --- Removing cities from favourites -- */

        removeFromFavourites(ilawa)

        /* --- Assertions -- */
        
        XCTAssertNotEqual(ilawa, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerCapitals)
    }

    func test_SearchBarCancelation()
    {
        let expectedCount = app.tables.cells.count

        let
        searchField = app.otherElements["cities-search"]
        searchField.tap()
        searchField.typeText("aaa")

        sleep(1)

        XCTAssertEqual(1, app.tables.cells.count)
        app.buttons["Anuluj"].tap()
        XCTAssertEqual(expectedCount, app.tables.cells.count)
    }
}
