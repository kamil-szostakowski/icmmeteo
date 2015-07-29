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
    
    private var currentDate = NSDate()
    private var dateFormatter = NSDateFormatter()
    private var selectedIndexes = [NSIndexPath]()
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    }
    
    // MARK: UITableViewDelegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 4;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(section == 0) {
            return 7;
        }
        
        if(section == 3) {
            return 5;
        }
        
        return 8;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let
        cell = tableView.dequeueReusableCellWithIdentifier("WamSettingsTimeItem", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "Lorem ipsum"
        cell.detailTextLabel?.text = "Dolor sit amet"
        cell.accessoryType =  find(selectedIndexes, indexPath) == nil ? .None : .Checkmark
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let
        cell = tableView.dequeueReusableCellWithIdentifier("WamSettingsHeader") as! UITableViewCell
        cell.textLabel?.text = dateFormatter.stringFromDate(currentDate)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let cellSelected = cell.accessoryType == UITableViewCellAccessoryType.Checkmark
        
        cell.accessoryType = cellSelected ? .None : .Checkmark
        
        if let index = find(selectedIndexes, indexPath) {
            selectedIndexes.removeAtIndex(index)
        }
        
        else {
            selectedIndexes.append(indexPath)
        }
    }
}