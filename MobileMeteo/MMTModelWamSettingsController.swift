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
    
    fileprivate let minMomentsCount = 3
    fileprivate let categoryTag = 100
    fileprivate var currentDate = Date()
    fileprivate var selectedIndexes = [IndexPath]()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnShow: UIBarButtonItem!
    @NSCopying var wamSettings: MMTWamSettings!
    
    var wamStore: MMTWamModelStore!
    
    // MARK: Overrides    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        btnShow.isEnabled = wamSettings.forecastSelectedMoments.count>=minMomentsCount
        analytics?.sendScreenEntryReport("Model WAM settings")
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: Actions
    
    func didSelectCategory(_ category: UITableViewCell)
    {
        let section = sectionForTag(category.tag)
        let moments = wamSettings.forecastMomentsGrouppedByDay[section].map(){ $0.date }
        
        wamSettings.setMomentsSelection(moments, selected: category.isSelected)
        btnShow.isEnabled = wamSettings.forecastSelectedMoments.count>=minMomentsCount
        tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return wamSettings.forecastMomentsGrouppedByDay.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {        
        return wamSettings.forecastMomentsGrouppedByDay[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let moment = momentForIndexPath(indexPath)
        let date = wamSettings.forecastMomentsGrouppedByDay[indexPath.section][indexPath.row].date        
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        
        let
        cell = tableView.dequeueReusableCell(withIdentifier: "WamSettingsTimeItem", for: indexPath) 
        cell.textLabel?.text = String(format: MMTFormat.TZeroPlus, tZeroPlus)
        cell.detailTextLabel?.text = DateFormatter.utcFormatter.string(from: date)
        cell.accessoryType =  moment.selected ? .checkmark : .none
        cell.accessibilityIdentifier = "WamSettingsMoment: t0 +\(tZeroPlus)h"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let date = wamSettings.forecastMomentsGrouppedByDay[section].first!.date
        
        let
        cell = tableView.dequeueReusableCell(withIdentifier: "WamSettingsHeader")!
        cell.textLabel?.text = DateFormatter.shortDateOnlyStyle.string(from: date)
        cell.isSelected = isSectionSelected(section)
        cell.tag = tagForSection(section)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let moment = momentForIndexPath(indexPath)
        let selected = tableView.cellForRow(at: indexPath)!.accessoryType == .none
        
        wamSettings.setMomentSelection(moment.date, selected: selected)
        btnShow.isEnabled = wamSettings.forecastSelectedMoments.count>=minMomentsCount
        tableView.reloadData()
    }
    
    // MARK: Helper methods
    
    fileprivate func momentForIndexPath(_ indexPath: IndexPath) -> MMTWamMoment
    {
        return wamSettings.forecastMomentsGrouppedByDay[indexPath.section][indexPath.row]
    }
    
    fileprivate func isSectionSelected(_ section: Int) -> Bool
    {
        return wamSettings.forecastMomentsGrouppedByDay[section].map() { $0.selected }.reduce(true) { $0 && $1 }
    }
    
    fileprivate func tagForSection(_ section: Int) -> Int
    {
        return categoryTag+section
    }
    
    fileprivate func sectionForTag(_ tag: Int) -> Int
    {
        return tag-categoryTag
    }
}
