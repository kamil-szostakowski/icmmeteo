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
    
    // MARK: Setup methods
    
    override func setUp()
    {
        super.setUp()
        
        settings = MMTWamSettings(
        [
            (date: TT.getDate(2015, 07, 30, 3), selected: false),
            (date: TT.getDate(2015, 07, 30, 6), selected: false),
            (date: TT.getDate(2015, 07, 30, 9), selected: false),
            (date: TT.getDate(2015, 07, 30, 12), selected: false),
            (date: TT.getDate(2015, 07, 30, 15), selected: false),
            (date: TT.getDate(2015, 07, 30, 18), selected: false),
            (date: TT.getDate(2015, 07, 30, 21), selected: false),
            
            (date: TT.getDate(2015, 07, 31, 0), selected: false),
            (date: TT.getDate(2015, 07, 31, 3), selected: false),
            (date: TT.getDate(2015, 07, 31, 6), selected: false),
            (date: TT.getDate(2015, 07, 31, 9), selected: false),
            (date: TT.getDate(2015, 07, 31, 12), selected: false),
            (date: TT.getDate(2015, 07, 31, 15), selected: false),
            (date: TT.getDate(2015, 07, 31, 18), selected: false),
            (date: TT.getDate(2015, 07, 31, 21), selected: false),
            
            (date: TT.getDate(2015, 08, 01, 0), selected: false),
            (date: TT.getDate(2015, 08, 01, 3), selected: false),
            (date: TT.getDate(2015, 08, 01, 6), selected: false),
            (date: TT.getDate(2015, 08, 01, 9), selected: false),
            (date: TT.getDate(2015, 08, 01, 12), selected: false),
            (date: TT.getDate(2015, 08, 01, 15), selected: false),
            (date: TT.getDate(2015, 08, 01, 18), selected: false),
            (date: TT.getDate(2015, 08, 01, 21), selected: false),
            
            (date: TT.getDate(2015, 08, 02, 0), selected: false),
            (date: TT.getDate(2015, 08, 02, 3), selected: false),
            (date: TT.getDate(2015, 08, 02, 6), selected: false),
            (date: TT.getDate(2015, 08, 02, 9), selected: false),
            (date: TT.getDate(2015, 08, 02, 12), selected: false),
        ]);
    }
    
    override func tearDown()
    {
        settings = nil;
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func testSelectedForecastCategoriesForDefaultSettings()
    {
        let expected: [MMTWamCategory] = [.TideHeight, .AvgTidePeriod, .SpectrumPeakPeriod]
        
        XCTAssertEqual(expected, settings.selectedCategories)
    }
    
    func testDisableAllForecastCategories()
    {
        settings.setCategory(.TideHeight, enabled: false)
        settings.setCategory(.AvgTidePeriod, enabled: false)
        settings.setCategory(.SpectrumPeakPeriod, enabled: false)
        
        XCTAssertEqual([], settings.selectedCategories)
    }
    
    func testDisableSelectedForecastCategories()
    {
        settings.setCategory(.TideHeight, enabled: false)
        settings.setCategory(.AvgTidePeriod, enabled: false)
        settings.setCategory(.TideHeight, enabled: true)
        
        XCTAssertEqual([.TideHeight, .SpectrumPeakPeriod], settings.selectedCategories)
    }    
    
    func testForecastDaysCount()
    {
        XCTAssertEqual(4, settings.forecastMomentsGrouppedByDay.count)
    }
    
    func testForecastMomentsCountPerDay()
    {
        let gruppedMoments = settings.forecastMomentsGrouppedByDay
        
        XCTAssertEqual(7, gruppedMoments[0].count)
        XCTAssertEqual(8, gruppedMoments[1].count)
        XCTAssertEqual(8, gruppedMoments[2].count)
        XCTAssertEqual(5, gruppedMoments[3].count)
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