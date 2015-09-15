//
//  MMTModelWamSettingsController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 23.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTModelWamSettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // MARK: Properties
    
    private let categoryTag = 100
    private var currentDate = NSDate()
    private var selectedIndexes = [NSIndexPath]()
    private var wamStore: MMTWamModelStore!
    
    @IBOutlet var tableView: UITableView!
    
    @NSCopying var wamSettings: MMTWamSettings!
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        wamStore = MMTWamModelStore(date: NSDate())
        let moments = wamSettings.forecastMomentsGrouppedByDay
        
        return
    }
    
    // MARK: Actions
    
    func didSelectCategory(category: UITableViewCell)
    {
        let section = sectionForRag(category.tag)
        let moments = wamSettings.forecastMomentsGrouppedByDay[section].map(){ $0.date }
        
        wamSettings.setMomentsSelection(moments, selected: category.selected)
        tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return wamSettings.forecastMomentsGrouppedByDay.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {        
        return wamSettings.forecastMomentsGrouppedByDay[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let moment = momentForIndexPath(indexPath)
        let date = wamSettings.forecastMomentsGrouppedByDay[indexPath.section][indexPath.row].date        
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        
        let
        cell = tableView.dequeueReusableCellWithIdentifier("WamSettingsTimeItem", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = String(NSString(format: MMTFormat.TZeroPlus, tZeroPlus))
        cell.detailTextLabel?.text = NSDateFormatter.shortStyleUtcDatetime(date)
        cell.accessoryType =  moment.selected ? .Checkmark : .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let date = wamSettings.forecastMomentsGrouppedByDay[section].first!.date
        
        let
        cell = tableView.dequeueReusableCellWithIdentifier("WamSettingsHeader") as! UITableViewCell
        cell.textLabel?.text = NSDateFormatter.shortStyle.stringFromDate(date)
        cell.selected = isSectionSelected(section)
        cell.tag = tagForSection(section)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let moment = momentForIndexPath(indexPath)
        let selected = tableView.cellForRowAtIndexPath(indexPath)!.accessoryType == .None
        
        wamSettings.setMomentSelection(moment.date, selected: selected)
        tableView.reloadData()
    }
    
    // MARK: Helper methods
    
    private func momentForIndexPath(indexPath: NSIndexPath) -> MMTWamMoment
    {
        return wamSettings.forecastMomentsGrouppedByDay[indexPath.section][indexPath.row]
    }
    
    private func isSectionSelected(section: Int) -> Bool
    {
        return wamSettings.forecastMomentsGrouppedByDay[section].map() { $0.selected }.reduce(true) { $0 && $1 }
    }
    
    private func tagForSection(section: Int) -> Int
    {
        return categoryTag+section
    }
    
    private func sectionForRag(tag: Int) -> Int
    {
        return tag-categoryTag
    }
}