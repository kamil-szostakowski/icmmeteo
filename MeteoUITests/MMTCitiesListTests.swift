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
    static var onceToken: dispatch_once_t = 0
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
        
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        app = XCUIApplication()

        dispatch_once(&MMTCitiesListTests.onceToken){
            self.app.launchArguments = ["CLEANUP_DB"]
        }
        
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
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.elementBoundByIndex(0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(bydgoszcz, app.tables.cells.elementBoundByIndex(2).label)
        XCTAssertEqual(krakow, app.tables.cells.elementBoundByIndex(3).label)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(4).label)
        XCTCheckHeader("Miasta wojewódzkie", index: 5)
    }
    
    func test02_RemovingPedefinedCitiesFromFavourites()
    {
        removeFromFavourites(krakow)
        removeFromFavourites(bydgoszcz)
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.elementBoundByIndex(0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(2).label)
        XCTCheckHeader(headerCapitals, index: 3)
    }
    
    func test03_AddingFoundCityToFavourites()
    {
        let
        searchField = app.tables.searchFields["szukaj miasta"]
        searchField.tap()
        searchField.typeText("Iława")
        
        sleep(3)
        
        XCTAssertEqual(ilawa, app.tables.cells.elementBoundByIndex(0).label)
        XCTAssertEqual(locationNotFound, app.tables.cells.elementBoundByIndex(1).label)
        
        addToFavourites(ilawa)
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.elementBoundByIndex(0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(ilawa, app.tables.cells.elementBoundByIndex(2).label)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(3).label)
        XCTCheckHeader(headerCapitals, index: 4)
    }
    
    func test04_RemovingFoundCityFromFavourites()
    {
        removeFromFavourites(ilawa)
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.elementBoundByIndex(0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(2).label)
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
        map = app.maps.elementBoundByIndex(0)
        map.pinchWithScale(4, velocity: 4)
        map.pressForDuration(1.3)
        
        app.navigationBars["Wybierz lokalizację"].buttons["Pokaż"].tap()
        
        let navBar = app.navigationBars.elementBoundByIndex(0)
        
        expectationForPredicate(NSPredicate(format: "enabled == true"), evaluatedWithObject: navBar.buttons["star outline"]) {
            
            navBar.buttons["star outline"].tap()
            navBar.buttons["Zatrzymaj"].tap()
            
            XCTAssertEqual(self.detailedMaps, self.app.tables.cells.elementBoundByIndex(0).label)
            self.XCTCheckHeader(self.headerFavourites, index: 1)
            self.XCTCheckHeader(self.headerCapitals, index: 4)
            
            return true
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func test06_RemovingCityPointedOnMapFromFavourites()
    {
        removeFromFavourites(app.tables.cells.elementBoundByIndex(2).label)
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.elementBoundByIndex(0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(2).label)
        XCTCheckHeader(headerCapitals, index: 3)
    }
    
    func test07_FavouritesListOnCoampsTab()
    {
        app.tabBars.buttons["Model COAMPS"].tap()
        
        /* --- Assertions -- */
        
        XCTAssertEqual(detailedMaps, app.tables.cells.elementBoundByIndex(0).label)
        XCTCheckHeader(headerFavourites, index: 1)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(2).label)
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
    
    func addToFavourites(elementName: String)
    {
        app.tables.cells[elementName].tap()
        
        let navBar = self.app.navigationBars.elementBoundByIndex(0)
        
        expectationForPredicate(NSPredicate(format: "enabled == true"), evaluatedWithObject: navBar.buttons["star outline"]) {

            navBar.buttons["star outline"].tap()
            navBar.buttons["Zatrzymaj"].tap()
            return true
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func removeFromFavourites(elementName: String)
    {
        app.tables.cells[elementName].tap()
        
        let navBar = self.app.navigationBars.elementBoundByIndex(0)
        
        expectationForPredicate(NSPredicate(format: "enabled == true"), evaluatedWithObject: navBar.buttons["star"]) {
            
            navBar.buttons["star"].tap()
            navBar.buttons["Zatrzymaj"].tap()
            return true
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func XCTCheckHeader(label: String, index: UInt)
    {
        XCTAssertEqual("CitiesListHeader", app.tables.cells.elementBoundByIndex(index).identifier)
        XCTAssertEqual(label, app.tables.cells.elementBoundByIndex(index).label)
    }
}