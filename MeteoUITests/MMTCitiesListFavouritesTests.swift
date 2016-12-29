//
//  MMTCitiesList+FavouritesTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTCitiesListFavouritesTests: MMTCitiesListTestCase
{
    func test_AddingAndRemovingPedefinedCitiesFromFavourites()
    {
        /* --- Adding cities to favourites -- */

        addToFavourites(bydgoszcz)
        addToFavourites(krakow)
        app.tables.element.swipeUp()
        addToFavourites(torun)
        app.tables.element.swipeDown()

        /* --- Assertions -- */

        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerFavourites)
        XCTAssertEqual(bydgoszcz, app.tables.cells.element(boundBy: 2).label)
        XCTAssertEqual(krakow, app.tables.cells.element(boundBy: 3).label)
        XCTAssertEqual(torun, app.tables.cells.element(boundBy: 4).label)
        XCTCheckHeader(headerCapitals)

        /* --- Removing cities from favourites -- */

        removeFromFavourites(krakow)
        removeFromFavourites(bydgoszcz)

        /* --- Assertions -- */

        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerFavourites)
        XCTAssertEqual(torun, app.tables.cells.element(boundBy: 2).label)
        XCTCheckHeader(headerCapitals)
    }

    func test_FavouritesListOnCoampsTab()
    {
        app.tabBars.buttons["Model COAMPS"].tap()

        /* --- Assertions -- */

        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTAssertEqual(bialystok, app.tables.cells.element(boundBy: 1).label)
        XCTCheckHeader(headerCapitals)
    }
}
