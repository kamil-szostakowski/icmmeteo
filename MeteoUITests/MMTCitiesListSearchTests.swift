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
        searchField = app.tables.searchFields["szukaj miasta"]
        searchField.tap()
        searchField.typeText("Iława")

        sleep(3)

        XCTAssertEqual(ilawa, app.tables.cells.element(boundBy: 0).label)
        XCTAssertEqual(locationNotFound, app.tables.cells.element(boundBy: 1).label)

        addToFavourites(ilawa)

        /* --- Assertions -- */
        
        XCTCheckHeader(headerFavourites)
        XCTAssertEqual(ilawa, app.tables.cells.element(boundBy: 0).label)
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
        searchField = app.tables.searchFields["szukaj miasta"]
        searchField.tap()
        searchField.typeText("aaa")

        sleep(3)

        XCTAssertEqual(1, app.tables.cells.count)
        app.tables.buttons["Anuluj"].tap()
        XCTAssertEqual(expectedCount, app.tables.cells.count)
    }
}
