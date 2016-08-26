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
    
    fileprivate var meteorogramType: String {
        return meteorogramStore is MMTUmModelStore ? "UM" : "COAMPS"
    }
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        analytics?.sendScreenEntryReport("Detailed maps: \(meteorogramType)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return meteorogramStore.detailedMaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let
        cell = tableView.dequeueReusableCell(withIdentifier: "DetailedMapCell", for: indexPath)
        cell.textLabel?.text = MMTLocalizedStringWithFormat("detailed-maps.\(meteorogramStore.detailedMaps[indexPath.row].rawValue)")
        
        return cell
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return .portrait
    }
}
