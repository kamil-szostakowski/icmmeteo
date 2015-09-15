//
//  MMTWamSettings.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 29.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

private typealias MMTWamMomentGroups = [Int: [MMTWamMoment]]

public class MMTWamSettings: NSObject, NSCopying
{
    // MARK: Properties        
    
    public var selectedCategory: MMTWamCategory?
    
    public var forecastMoments: [MMTWamMoment]
    
    public var forecastSelectedMoments: [MMTWamMoment]
    {
        return forecastMoments.filter(){ $0.selected }
    }
    
    public var forecastMomentsGrouppedByDay: [[MMTWamMoment]]
    {
        return getOrderedArrayOfGroups(getGroupedMoments(forecastMoments))
    }
    
    public override var description: String
    {
        return "<MMTWamSettings \n moments: \(forecastMomentsGrouppedByDay.description)>"
    }
    
    // MARK: Initializers
    
    public init(_ moments: [MMTWamMoment])
    {
        forecastMoments = moments        
        super.init()
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
    
    private func keyForDate(date: NSDate) -> Int
    {
        let units: NSCalendarUnit = (.CalendarUnitYear)|(.CalendarUnitMonth)|(.CalendarUnitDay)
        let components = NSCalendar.currentCalendar().components(units, fromDate: date)
        
        return Int(NSCalendar.currentCalendar().dateFromComponents(components)!.timeIntervalSince1970)
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject
    {
        let
        settings = MMTWamSettings([])
        settings.selectedCategory = selectedCategory
        settings.forecastMoments = forecastMoments

        return settings
    }
}