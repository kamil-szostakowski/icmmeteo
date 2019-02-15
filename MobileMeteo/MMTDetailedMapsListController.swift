//
//  MMTDetailedMapsListController.swift
//  MobileMeteo
//
//  Created by Kamil on 31.07.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import MeteoModel
import MeteoUIKit

class MMTDetailedMapsListController: UIViewController
{
    // MARK: Outlets
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: Properties
    var selectedDetailedMap: MMTDetailedMap!
    var selectedClimateModel: MMTClimateModel! {
        didSet {
            segmentControl.selectedModelType = selectedClimateModel.type
            if oldValue != nil {
                tableView.reloadData()
            }
        }
    }
}

// Lifecycle extension
extension MMTDetailedMapsListController
{
    // MARK: Controller methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationBar.accessibilityIdentifier = "detailed-maps-list-screen"
        selectedClimateModel = MMTUmClimateModel()
        
        segmentControl.selectedSegmentIndex = 0
        analytics?.sendScreenEntryReport("Detailed maps")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let previewController = segue.destination as? MMTDetailedMapPreviewController else {
            return
        }
                
        previewController.detailedMap = selectedDetailedMap
    }
}

// Actions extension
extension MMTDetailedMapsListController
{
    // MARK: Actions
    @IBAction func selectedModelDidChange(_ sender: UISegmentedControl)
    {
        guard let selectedModel = sender.selectedModelType?.model else {
            return
        }
        
        analytics?.sendUserActionReport(.DetailedMaps, action: .DetailedMapDidSelectModel, actionLabel: selectedModel.type.rawValue)
        selectedClimateModel = selectedModel
    }
    
    @IBAction func unwindToListOfDetailedMaps(_ unwindSegue: UIStoryboardSegue)
    {
    }
}

// UITableViewDelegate extension
extension MMTDetailedMapsListController : UITableViewDataSource, UITableViewDelegate
{
    // MARK: Table view methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return selectedClimateModel.detailedMaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let
        cell = tableView.dequeueReusableCell(withIdentifier: "DetailedMapCell", for: indexPath)
        cell.textLabel?.text = MMTLocalizedStringWithFormat("detailed-maps.\(selectedClimateModel.detailedMaps[indexPath.row].type.rawValue)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedDetailedMap = selectedClimateModel.detailedMaps[indexPath.row]
        perform(segue: .DisplayDetailedMap, sender: self)
    }
}
