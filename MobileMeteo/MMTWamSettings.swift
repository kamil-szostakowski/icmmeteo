//
//  MMTWamSettings.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 29.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

public typealias MMTWamMomentGroups = [String: [MMTWamMoment]]

public class MMTWamSettings: NSObject
{
    // MARK: Properties
    
    private var categories: [MMTWamCategory] = [.TideHeight, .AvgTidePeriod, .SpectrumPeakPeriod]
    
    public var forecastMoments: [MMTWamMoment]
    
    public var forecastSelectedMoments: [MMTWamMoment]
    {
        return forecastMoments.filter(){ $0.selected }
    }
    
    public var selectedCategories: [MMTWamCategory]
    {
        return categories.sorted(){ $0.rawValue < $1.rawValue }
    }
    
    public var forecastMomentsGrouppedByDay: [[MMTWamMoment]]
    {
        return getOrderedArrayOfGroups(getGroupedMoments(forecastMoments))
    }
    
    public override var description: String
    {
        return "<MMTWamSettings \n categories: \(selectedCategories.description) \n moments: \(forecastMomentsGrouppedByDay.description)>"
    }
    
    // MARK: Initializers
    
    public init(_ moments: [MMTWamMoment])
    {
        forecastMoments = moments        
        super.init()
    }
    
    // MARK: Methods
    
    public func setCategory(category: MMTWamCategory, enabled: Bool)
    {
        let found = find(categories, category)
        
        if found != nil && !enabled {
            categories.removeAtIndex(found!)
        }
        
        else if found == nil && enabled {
            categories.append(category)
        }        
    }
    
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