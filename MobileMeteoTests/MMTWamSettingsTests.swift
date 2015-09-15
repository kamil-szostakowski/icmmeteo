//
//  MMTWamSettingsTests.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 29.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import XCTest
import Foundation
import MobileMeteo

class MMTWamSettingsTests: XCTestCase
{
    // MARK: Properties
    
    var settings: MMTWamSettings!
    var momentsOnTurnOfTheMonth: [MMTWamMoment]!
    var moments: [MMTWamMoment]!
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        momentsOnTurnOfTheMonth =
        [
            (date: TT.getDate(2015, 07, 30, 3), selected: false),
            (date: TT.getDate(2015, 07, 30, 6), selected: false),
            (date: TT.getDate(2015, 07, 31, 3), selected: false),
            (date: TT.getDate(2015, 07, 31, 6), selected: false),
            (date: TT.getDate(2015, 08, 01, 0), selected: false),
            (date: TT.getDate(2015, 08, 02, 0), selected: false),
        ];
        
        moments =
        [
            (date: TT.getDate(2015, 07, 08, 3), selected: false),
            (date: TT.getDate(2015, 07, 08, 6), selected: false),
            (date: TT.getDate(2015, 07, 09, 0), selected: false),
            (date: TT.getDate(2015, 07, 09, 3), selected: false),
            (date: TT.getDate(2015, 07, 10, 0), selected: false),
            (date: TT.getDate(2015, 07, 11, 0), selected: false),
        ]
        
        settings = MMTWamSettings(momentsOnTurnOfTheMonth)
    }
    
    override func tearDown()
    {
        momentsOnTurnOfTheMonth = nil
        moments = nil
        settings = nil
        
        super.tearDown()
    }
    
    // MARK: Test methods       
    
    func testForecastDaysCount()
    {
        XCTAssertEqual(4, settings.forecastMomentsGrouppedByDay.count)
    }
    
    func testForecastMomentsCountPerDay()
    {
        let gruppedMoments = settings.forecastMomentsGrouppedByDay
        
        XCTAssertEqual(2, gruppedMoments[0].count)
        XCTAssertEqual(2, gruppedMoments[1].count)
        XCTAssertEqual(1, gruppedMoments[2].count)
        XCTAssertEqual(1, gruppedMoments[3].count)
    }
    
    func testForecastMomentsOrder()
    {
        let gruppedMoments = MMTWamSettings(moments).forecastMomentsGrouppedByDay
        
        XCTAssertEqual(TT.getDate(2015, 07, 08, 3), gruppedMoments[0].first!.date)
        XCTAssertEqual(TT.getDate(2015, 07, 09, 0), gruppedMoments[1].first!.date)
        XCTAssertEqual(TT.getDate(2015, 07, 10, 0), gruppedMoments[2].first!.date)
        XCTAssertEqual(TT.getDate(2015, 07, 11, 0), gruppedMoments[3].first!.date)
    }
    
    func testForecastMomentsOrderForTheTurnOfTheMont()
    {
        let gruppedMoments = settings.forecastMomentsGrouppedByDay
        
        XCTAssertEqual(TT.getDate(2015, 07, 30, 3), gruppedMoments[0].first!.date)
        XCTAssertEqual(TT.getDate(2015, 07, 31, 3), gruppedMoments[1].first!.date)
        XCTAssertEqual(TT.getDate(2015, 08, 01, 0), gruppedMoments[2].first!.date)
        XCTAssertEqual(TT.getDate(2015, 08, 02, 0), gruppedMoments[3].first!.date)
    }
    
    func testRetreiveForecastMoment()
    {
        let date1 = TT.getDate(2015, 7, 30, 3)
        let date2 = TT.getDate(2015, 8, 31, 6)

        XCTAssertTrue(settings.momentForDate(date1) != nil)
        XCTAssertTrue(settings.momentForDate(date2) == nil)
    }
    
    func testForecastMomentsSelection()
    {
        let date1 = TT.getDate(2015, 7, 30, 3)
        let date2 = TT.getDate(2015, 7, 30, 6)
        
        settings.setMomentSelection(date1, selected: true)
        settings.setMomentSelection(date2, selected: true)
        
        XCTAssertTrue(settings.momentForDate(date1)!.selected)
        XCTAssertTrue(settings.momentForDate(date2)!.selected)
    }
    
    func testSelectedForecastMoments()
    {
        let date1 = TT.getDate(2015, 7, 30, 3)
        let date2 = TT.getDate(2015, 7, 30, 6)
        
        settings.setMomentSelection(date1, selected: true)
        settings.setMomentSelection(date2, selected: true)
        
        XCTAssertEqual(2, settings.forecastSelectedMoments.count)
    }
    
    func testForecastMomentsDeselection()
    {
        let date = TT.getDate(2015, 7, 30, 3)
        
        settings.setMomentSelection(date, selected: true)
        XCTAssertTrue(settings.momentForDate(date)!.selected)
        
        settings.setMomentSelection(date, selected: false)
        XCTAssertFalse(settings.momentForDate(date)!.selected)
    }
    
    func testForecastMomentsBulkSelection()
    {
        let dates = [
            TT.getDate(2015, 7, 30, 3),
            TT.getDate(2015, 7, 30, 6),
        ]
        
        settings.setMomentsSelection(dates, selected: true)
        
        XCTAssertTrue(settings.momentForDate(dates[0])!.selected)
        XCTAssertTrue(settings.momentForDate(dates[1])!.selected)
    }
}