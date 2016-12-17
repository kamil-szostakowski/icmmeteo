//
//  MMTCitiesListTestCase.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 27/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTCitiesListTestCase: XCTestCase
{
    // MARK: Properties

    let torun = "Toruń, Kujawsko-Pomorskie"
    let bydgoszcz = "Bydgoszcz, Kujawsko-Pomorskie"
    let krakow = "Kraków, Małopolskie"
    let ilawa = "Iława, Warmińsko-Mazurskie"
    let bialystok = "Białystok, Podlaskie"

    let detailedMaps = "Mapy szczegółowe"
    let headerFavourites = "Ulubione"
    let headerCapitals = "Miasta wojewódzkie"
    let locationNotFound = "Wskaż lokalizację na mapie"

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

        sleep(1)
    }

    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }

    // MARK: Helper methods

    func addToFavourites(_ elementName: String)
    {
        app.tables.cells[elementName].tap()

        let navBar = self.app.navigationBars.element(boundBy: 0)

        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: navBar.buttons["star outline"]) {

            navBar.buttons["star outline"].tap()
            navBar.buttons["Zatrzymaj"].tap()
            return true
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func removeFromFavourites(_ elementName: String)
    {
        app.tables.cells[elementName].tap()

        let navBar = self.app.navigationBars.element(boundBy: 0)

        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: navBar.buttons["star"]) {

            navBar.buttons["star"].tap()
            navBar.buttons["Zatrzymaj"].tap()
            return true
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func XCTCheckHeader(_ label: String)
    {
        let header = app.tables.children(matching: .staticText)[label]
        XCTAssertEqual(header.label, label)
    }
}
