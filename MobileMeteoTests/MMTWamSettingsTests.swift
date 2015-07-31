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
        
        let date = getDate(2015, 7, 30, 0)
        
        settings = MMTWamSettings(date, forecastLength: 84);
    }
    
    override func tearDown()
    {
        settings = nil;
        super.tearDown()
    }
    
    // MARK: Test methods
    
    func testSelectedForecastCategoriesForDefaultSettings()
    {
        XCTAssertTrue(settings.categoryTideHeightEnabled)
        XCTAssertTrue(settings.categoryAvgTidePeriodEnabled)
        XCTAssertTrue(settings.categorySpectrumPeakPeriodEnabled)
    }
    
    func testDisableForecastCategory()
    {
        settings.categoryTideHeightEnabled = false
        settings.categoryAvgTidePeriodEnabled = false
        settings.categorySpectrumPeakPeriodEnabled = false
        
        XCTAssertFalse(settings.categoryTideHeightEnabled)
        XCTAssertFalse(settings.categoryAvgTidePeriodEnabled)
        XCTAssertFalse(settings.categorySpectrumPeakPeriodEnabled)
    }
    
    func testForecastMomentsCount()
    {
        XCTAssertEqual(28, settings.forecastMoments.count)
    }
    
    func testForecastMoments()
    {
        var moments = settings.forecastMoments

        XCTAssertEqual(getDate(2015, 7, 30, 3), moments[0].date)
        XCTAssertEqual(getDate(2015, 7, 31, 9), moments[10].date)
        XCTAssertEqual(getDate(2015, 8, 1, 6), moments[17].date)
        XCTAssertEqual(getDate(2015, 8, 2, 12), moments[27].date)
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
        let date1 = getDate(2015, 7, 30, 3)
        let date2 = getDate(2015, 8, 31, 6)

        XCTAssertTrue(settings.momentForDate(date1) != nil)
        XCTAssertTrue(settings.momentForDate(date2) == nil)
    }
    
    func testForecastMomentsSelection()
    {
        let date1 = getDate(2015, 7, 30, 3)
        let date2 = getDate(2015, 7, 30, 6)
        
        settings.setMomentSelection(date1, selected: true)
        settings.setMomentSelection(date2, selected: true)
        
        XCTAssertTrue(settings.momentForDate(date1)!.selected)
        XCTAssertTrue(settings.momentForDate(date2)!.selected)
    }
    
    func testForecastMomentsDeselection()
    {
        let date = getDate(2015, 7, 30, 3)
        
        settings.setMomentSelection(date, selected: true)
        XCTAssertTrue(settings.momentForDate(date)!.selected)
        
        settings.setMomentSelection(date, selected: false)
        XCTAssertFalse(settings.momentForDate(date)!.selected)
    }
    
    func testForecastMomentsBulkSelection()
    {
        let dates = [
            getDate(2015, 7, 30, 3),
            getDate(2015, 7, 30, 6),
        ]
        
        settings.setMomentsSelection(dates, selected: true)
        
        XCTAssertTrue(settings.momentForDate(dates[0])!.selected)
        XCTAssertTrue(settings.momentForDate(dates[1])!.selected)
    }
    
    // MARK: Helper methods
    
    private func getDate(year: Int, _ month: Int, _ day: Int, _ hour: Int) -> NSDate
    {
        var components = NSDateComponents()
        components.timeZone = NSTimeZone(name: "UTC")
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
}