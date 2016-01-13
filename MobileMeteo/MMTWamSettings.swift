//
//  MMTWamSettings.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 29.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation

private typealias MMTWamMomentGroups = [Int: [MMTWamMoment]]

class MMTWamSettings: NSObject, NSCopying
{
    // MARK: Properties        
    
    var selectedCategory: MMTWamCategory?
    
    var forecastMoments: [MMTWamMoment]
    
    var forecastSelectedMoments: [MMTWamMoment]
    {
        return forecastMoments.filter(){ $0.selected }
    }
    
    var forecastMomentsGrouppedByDay: [[MMTWamMoment]]
    {
        return getOrderedArrayOfGroups(getGroupedMoments(forecastMoments))
    }
    
    override var description: String
    {
        return "<MMTWamSettings \n moments: \(forecastMomentsGrouppedByDay.description)>"
    }
    
    // MARK: Initializers
    
    init(_ moments: [MMTWamMoment])
    {
        forecastMoments = moments        
        super.init()
    }
    
    // MARK: Methods
    
    func momentForDate(date: NSDate) -> MMTWamMoment?
    {
        if let index = (forecastMoments.map(){ $0.date }).indexOf(date) {
            return forecastMoments[index]
        }
        return nil
    }
    
    func setMomentSelection(date: NSDate, selected: Bool)
    {
        if let index = (forecastMoments.map(){ $0.date }).indexOf(date) {
            forecastMoments[index].selected = selected
        }
    }
    
    func setMomentsSelection(dates: [NSDate], selected: Bool)
    {
        for date in dates {
            setMomentSelection(date, selected: selected)
        }
    }
    
    // MARK: Helper methods    
    
    private func getOrderedArrayOfGroups(groupedMoments: MMTWamMomentGroups) -> [[MMTWamMoment]]
    {
        let sortedLabels = groupedMoments.keys.sort { $0 < $1 }
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
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: date)
        return Int(NSCalendar.currentCalendar().dateFromComponents(components)!.timeIntervalSince1970)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let
        settings = MMTWamSettings([])
        settings.selectedCategory = selectedCategory
        settings.forecastMoments = forecastMoments

        return settings
    }
}