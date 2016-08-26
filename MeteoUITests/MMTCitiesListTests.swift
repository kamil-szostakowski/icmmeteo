//
//  MMTCitiesListScreenTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 06.11.2015.
//  Copyright © 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation

class MMTCitiesListTests: XCTestCase
{
    let torun = "Toruń, Kujawsko-Pomorskie"
    let bydgoszcz = "Bydgoszcz, Kujawsko-Pomorskie"
    let krakow = "Kraków, Małopolskie"
    let ilawa = "Iława, Warmińsko-Mazurskie"
    let detailedMaps = "Mapy szczegółowe"
    let locationNotFound = "Wskaż lokalizację na mapie"
    
    let headerFavourites = "Ulubione"
    let headerCapitals = "Miasta wojewódzkie"
    
    var app: XCUIApplication!
    static var onceToken: Int = 0
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIDevice.shared().orientation = .portrait
        
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown()
    {
        app.terminate()
        super.tearDown()
    }    
    
    // MARK: Test methods
    
    func test01_AddingPedefinedCitiesToFavourites()
    {
        addToFavourites(bydgoszcz)
        addToFavourites(krakow)
        app.tables.element.swipeUp()
        addToFavourites(torun)
        app.tables.element.swipeDown()
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(bydgoszcz, app.tables.cells.element(boundBy: 2).label)
        XCTAssertEqual(krakow, app.tables.cells.element(boundBy: 3).label)
        XCTAssertEqual(torun, app.tables.cells.element(boundBy: 4).label)
        XCTCheckHeader(headerCapitals, index: 5)
    }
    
    func test02_RemovingPedefinedCitiesFromFavourites()
    {
        removeFromFavourites(krakow)
        removeFromFavourites(bydgoszcz)
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(torun, app.tables.cells.element(boundBy: 2).label)
        XCTCheckHeader(headerCapitals, index: 3)
    }
    
    func test03_AddingFoundCityToFavourites()
    {
        let
        searchField = app.tables.searchFields["szukaj miasta"]
        searchField.tap()
        searchField.typeText("Iława")
        
        sleep(3)
        
        XCTAssertEqual(ilawa, app.tables.cells.element(boundBy: 0).label)
        XCTAssertEqual(locationNotFound, app.tables.cells.element(boundBy: 1).label)
        
        addToFavourites(ilawa)
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(ilawa, app.tables.cells.element(boundBy: 2).label)
        XCTAssertEqual(torun, app.tables.cells.element(boundBy: 3).label)
        XCTCheckHeader(headerCapitals, index: 4)
    }
    
    func test04_RemovingFoundCityFromFavourites()
    {
        removeFromFavourites(ilawa)
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(torun, app.tables.cells.element(boundBy: 2).label)
        XCTCheckHeader(headerCapitals, index: 3)
    }
    
    func test05_AddingCityPointedOnMapToFavourites()
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
            self.XCTCheckHeader(self.headerFavourites, index: 1)
            self.XCTCheckHeader(self.headerCapitals, index: 4)
            
            return true
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func test06_RemovingCityPointedOnMapFromFavourites()
    {
        removeFromFavourites(app.tables.cells.element(boundBy: 2).label)
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(torun, app.tables.cells.element(boundBy: 2).label)
        XCTCheckHeader(headerCapitals, index: 3)
    }
    
    func test07_FavouritesListOnCoampsTab()
    {
        app.tabBars.buttons["Model COAMPS"].tap()
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.element(boundBy: 0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(torun, app.tables.cells.element(boundBy: 2).label)
        XCTCheckHeader(headerCapitals, index: 3)
    }
    
    func test08_SearchBarCancelation()
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
    
    // Helper methods
    
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
    
    func XCTCheckHeader(_ label: String, index: UInt)
    {
        
        XCTAssertEqual("CitiesListHeader", app.tables.cells.element(boundBy: index).identifier)
        XCTAssertEqual(label, app.tables.cells.element(boundBy: index).label)
    }
}
