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
    
    func momentForDate(_ date: Date) -> MMTWamMoment?
    {
        if let index = (forecastMoments.map(){ $0.date }).index(of: date) {
            return forecastMoments[index]
        }
        return nil
    }
    
    func setMomentSelection(_ date: Date, selected: Bool)
    {
        if let index = (forecastMoments.map(){ $0.date }).index(of: date) {
            forecastMoments[index].selected = selected
        }
    }
    
    func setMomentsSelection(_ dates: [Date], selected: Bool)
    {
        for date in dates {
            setMomentSelection(date, selected: selected)
        }
    }
    
    // MARK: Helper methods    
    
    fileprivate func getOrderedArrayOfGroups(_ groupedMoments: MMTWamMomentGroups) -> [[MMTWamMoment]]
    {
        let sortedLabels = groupedMoments.keys.sorted { $0 < $1 }
        var groups = [[MMTWamMoment]]()
        
        for label in sortedLabels {
            groups.append(groupedMoments[label]!)
        }
        
        return groups
    }
    
    fileprivate func getGroupedMoments(_ moments: [MMTWamMoment]) -> MMTWamMomentGroups
    {
        var groups = MMTWamMomentGroups()
        
        for (moment, selected) in moments
        {
            let groupKey = keyForDate(moment as Date)
            
            if groups[groupKey] == nil {
                groups[groupKey] = [MMTWamMoment]()
            }
            
            groups[groupKey]?.append((moment, selected))
        }
        
        return groups
    }
    
    fileprivate func keyForDate(_ date: Date) -> Int
    {
        let components = (Calendar.current as NSCalendar).components([.year, .month, .day], from: date)
        return Int(Calendar.current.date(from: components)!.timeIntervalSince1970)
    }
    
    func copy(with zone: NSZone?) -> Any
    {
        let
        settings = MMTWamSettings([])
        settings.selectedCategory = selectedCategory
        settings.forecastMoments = forecastMoments

        return settings
    }
}
