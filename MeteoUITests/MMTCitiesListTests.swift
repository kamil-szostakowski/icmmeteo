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
    
    var app: XCUIApplication!
    static var onceToken: dispatch_once_t = 0
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
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
        
        XCTCheckHeader("Ulubione", index: 0)
        XCTAssertEqual(bydgoszcz, app.tables.cells.elementBoundByIndex(1).label)
        XCTAssertEqual(krakow, app.tables.cells.elementBoundByIndex(2).label)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(3).label)
        XCTCheckHeader("Miasta wojewódzkie", index: 4)
    }
    
    func test02_RemovingPedefinedCitiesFromFavourites()
    {
        removeFromFavourites(krakow)
        removeFromFavourites(bydgoszcz)
        
        /* --- Assertions -- */
        
        XCTCheckHeader("Ulubione", index: 0)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(1).label)
        XCTCheckHeader("Miasta wojewódzkie", index: 2)
    }
    
    func test03_AddingFoundCityToFavourites()
    {
        let
        searchField = app.tables.searchFields["szukaj miasta"]
        searchField.tap()
        searchField.typeText("Iława")
        
        addToFavourites(ilawa)
        
        /* --- Assertions -- */
        
        XCTCheckHeader("Ulubione", index: 0)
        XCTAssertEqual(ilawa, app.tables.cells.elementBoundByIndex(1).label)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(2).label)
        XCTCheckHeader("Miasta wojewódzkie", index: 3)
    }
    
    func test04_RemovingFoundCityFromFavourites()
    {
        removeFromFavourites(ilawa)
        
        /* --- Assertions -- */
        
        XCTCheckHeader("Ulubione", index: 0)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(1).label)        
        XCTCheckHeader("Miasta wojewódzkie", index: 2)
    }
    
    func test05_AddingCityPointedOnMapToFavourites()
    {
        let
        searchField = app.tables.searchFields["szukaj miasta"]
        searchField.tap()
        searchField.typeText("aaa")
        
        app.tables.cells["Wskaż lokalizację na mapie"].tap()
        
        let
        map = app.maps.elementBoundByIndex(0)
        map.pinchWithScale(4, velocity: 4)
        map.pressForDuration(1.3)
        
        app.navigationBars["Wybierz lokalizację"].buttons["Pokaż"].tap()
        
        let
        navBar = app.navigationBars.elementBoundByIndex(0)
        navBar.buttons["star outline"].tap()
        navBar.buttons["Zatrzymaj"].tap()

        /* --- Assertions -- */
        
        XCTCheckHeader("Ulubione", index: 0)
        XCTCheckHeader("Miasta wojewódzkie", index: 3)
    }
    
    func test06_removingCityPointedOnMapFromFavourites()
    {
        removeFromFavourites(app.tables.cells.elementBoundByIndex(1).label)
        
        /* --- Assertions -- */
        
        XCTCheckHeader("Ulubione", index: 0)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(1).label)
        XCTCheckHeader("Miasta wojewódzkie", index: 2)
    }
    
    func test07_FavouritesListOnCoampsTab()
    {
        app.tabBars.buttons["Model COAMPS"].tap()
        
        /* --- Assertions -- */
        
        XCTCheckHeader("Ulubione", index: 0)
        XCTAssertEqual(torun, app.tables.cells.elementBoundByIndex(1).label)
        XCTCheckHeader("Miasta wojewódzkie", index: 2)
    }
    
    // Helper methods
    
    func addToFavourites(elementName: String)
    {
        app.tables.cells[elementName].tap()
        
        let
        navBar = self.app.navigationBars.elementBoundByIndex(0)
        navBar.buttons["star outline"].tap()
        navBar.buttons["Zatrzymaj"].tap()
    }
    
    func removeFromFavourites(elementName: String)
    {
        app.tables.cells[elementName].tap()
        
        let
        navBar = self.app.navigationBars.elementBoundByIndex(0)
        navBar.buttons["star"].tap()
        navBar.buttons["Zatrzymaj"].tap()
    }
    
    func XCTCheckHeader(label: String, index: UInt)
    {
        XCTAssertEqual("CitiesListHeader", app.tables.cells.elementBoundByIndex(index).identifier)
        XCTAssertEqual(label, app.tables.cells.elementBoundByIndex(index).label)
    }
}