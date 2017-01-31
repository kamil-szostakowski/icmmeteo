//
//  MMTDetailedMapsListController.swift
//  MobileMeteo
//
//  Created by Kamil on 31.07.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTDetailedMapsListController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: Properties
    
    private var meteorogramStore: MMTDetailedMapsStore!
    private var selectedDetailedMap: MMTDetailedMap!
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setupModelStore()
        analytics?.sendScreenEntryReport("Detailed maps")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let previewController = segue.destination as? MMTDetailedMapPreviewController else {
            return
        }

        previewController.climateModel = meteorogramStore.climateModel
        previewController.detailedMap = selectedDetailedMap
    }

    // MARK: Setup methods

    private func setupModelStore()
    {
        meteorogramStore = MMTDetailedMapsStore(model: MMTUmClimateModel(), date: Date())
        segmentControl.selectedSegmentIndex = 0
    }

    // MARK: Table view methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return meteorogramStore.climateModel.detailedMaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let
        cell = tableView.dequeueReusableCell(withIdentifier: "DetailedMapCell", for: indexPath)
        cell.textLabel?.text = MMTLocalizedStringWithFormat("detailed-maps.\(meteorogramStore.climateModel.detailedMaps[indexPath.row].type.rawValue)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedDetailedMap = meteorogramStore.climateModel.detailedMaps[indexPath.row]
        performSegue(withIdentifier: MMTSegue.DisplayDetailedMap, sender: self)
    }

    // MARK: Actions

    @IBAction func selectedModelDidChange(_ sender: UISegmentedControl)
    {
        guard let selectedSegmentTitle = sender.titleForSegment(at: sender.selectedSegmentIndex) else {
            return
        }

        analytics?.sendUserActionReport(.DetailedMaps, action: .DetailedMapDidSelectModel, actionLabel: selectedSegmentTitle)

        if selectedSegmentTitle == MMTClimateModelType.UM.rawValue {
            meteorogramStore = MMTDetailedMapsStore(model: MMTUmClimateModel(), date: Date())
        }

        if selectedSegmentTitle == MMTClimateModelType.COAMPS.rawValue {
            meteorogramStore = MMTDetailedMapsStore(model: MMTCoampsClimateModel(), date: Date())
        }

        tableView.reloadData()
    }
    
    @IBAction func unwindToListOfDetailedMaps(_ unwindSegue: UIStoryboardSegue)
    {        
    }
}
