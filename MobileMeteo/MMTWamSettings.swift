//
//  MMTWamSettings.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 29.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public typealias MMTWamMoment = (date: NSDate, selected: Bool)
public typealias MMTWamMomentGroups = [String: [MMTWamMoment]]

public class MMTWamSettings: NSObject
{
    // MARK: Properties
    
    private let momentLength: Int
    private let forecastStart: NSDate
    public let forecastLength: Int
    
    public var categoryTideHeightEnabled: Bool = true
    public var categoryAvgTidePeriodEnabled: Bool = true
    public var categorySpectrumPeakPeriodEnabled: Bool = true
    
    public var forecastMoments: [MMTWamMoment]
    
    public var forecastMomentsGrouppedByDay: [[MMTWamMoment]] {
        return getOrderedArrayOfGroups(getGroupedMoments(forecastMoments))
    }
    
    public override var description: String
    {
        return "<MMTWamSettings \n categoryTideHeightEnabled: \(categoryTideHeightEnabled) \n categoryAvgTidePeriodEnabled: \(categoryAvgTidePeriodEnabled) \n categorySpectrumPeakPeriodEnabled: \(categorySpectrumPeakPeriodEnabled) \n moments: \(forecastMomentsGrouppedByDay.description)>"
    }
    
    // MARK: Initializers
    
    public init(_ date: NSDate, forecastLength lenght: Int)
    {
        momentLength = 3
        forecastLength = lenght
        forecastStart = date
        forecastMoments = [MMTWamMoment]()
        
        super.init()

        generateMoments()
    }
    
    public convenience override init()
    {
        self.init(NSDate(), forecastLength: 84)
    }
    
    // MARK: Methods
    
    public func momentForDate(date: NSDate) -> MMTWamMoment?
    {
        if let index = find(forecastMoments.map(){ $0.date }, date) {
            return forecastMoments[index]
        }
        return nil
    }
    
    public func setMomentSelection(date: NSDate, selected: Bool)
    {
        if let index = find(forecastMoments.map(){ $0.date }, date) {
            forecastMoments[index].selected = selected
        }
    }
    
    public func setMomentsSelection(dates: [NSDate], selected: Bool)
    {
        for date in dates {
            setMomentSelection(date, selected: selected)
        }
    }
    
    // MARK: Helper methods
    
    private func generateMoments()
    {
        let momentsCount = forecastLength/momentLength
        for index in 1...momentsCount
        {
            let momentOffset = NSTimeInterval(index*momentLength*3600)
            let moment = forecastStart.dateByAddingTimeInterval(momentOffset)
            
            forecastMoments.append((date: moment, selected: false))
        }
    }
    
    private func getOrderedArrayOfGroups(groupedMoments: MMTWamMomentGroups) -> [[MMTWamMoment]]
    {
        let sortedLabels = groupedMoments.keys.array.sorted { $0 < $1 }
        var groups = [[MMTWamMoment]]()
        
        for label in sortedLabels {
            groups.append(groupedMoments[label]!)
        }
        
        return groups
    }
    
    private func getGroupedMoments(moments: [MMTWamMoment]) -> MMTWamMomentGroups
    {
        var groups = MMTWamMomentGroups()
        
        for (moment, selected) in moments
        {
            let groupKey = keyForDate(moment)
            
            if groups[groupKey] == nil {
                groups[groupKey] = [MMTWamMoment]()
            }
            
            groups[groupKey]?.append((moment, selected))
        }
        
        return groups
    }
    
    private func keyForDate(date: NSDate) -> String
    {
        let year = NSCalendar.currentCalendar().component(.CalendarUnitYear, fromDate: date)
        let month = NSCalendar.currentCalendar().component(.CalendarUnitMonth, fromDate: date)
        let day = NSCalendar.currentCalendar().component(.CalendarUnitDay, fromDate: date)
        
        return "\(year)\(month)\(day)"
    }
}