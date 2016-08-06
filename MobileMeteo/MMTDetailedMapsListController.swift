//
//  MMTDetailedMapsListController.swift
//  MobileMeteo
//
//  Created by Kamil on 31.07.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTDetailedMapsListController: UIViewController, UITableViewDataSource, UITableViewDelegate, MMTGridClimateModelController
{
    // MARK: Outlets
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: Properties
    
    var meteorogramStore: MMTGridClimateModelStore!
    
    private var meteorogramType: String {
        return meteorogramStore is MMTUmModelStore ? "UM" : "COAMPS"
    }
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        analytics?.sendScreenEntryReport("Detailed maps: \(meteorogramType)")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return meteorogramStore.detailedMaps.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let
        cell = tableView.dequeueReusableCellWithIdentifier("DetailedMapCell", forIndexPath: indexPath)
        cell.textLabel?.text = MMTLocalizedStringWithFormat("detailed-maps.\(meteorogramStore.detailedMaps[indexPath.row].rawValue)")
        
        return cell
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return .Portrait
    }
}