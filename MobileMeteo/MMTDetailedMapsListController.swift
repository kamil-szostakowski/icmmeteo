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
    
    // MARK: Properties
    
    var meteorogramStore: MMTDetailedMapsStore!

    private var selectedDetailedMap: MMTDetailedMap!

    private var meteorogramType: String {
        return meteorogramStore is MMTUmModelStore ? "UM" : "COAMPS"
    }
    
    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        analytics?.sendScreenEntryReport("Detailed maps: \(meteorogramType)")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let previewController = segue.destination as? MMTDetailedMapPreviewController else {
            return
        }

        previewController.meteorogramStore = meteorogramStore
        previewController.detailedMap = selectedDetailedMap
    }

    // MARK: Table view methods

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedDetailedMap = meteorogramStore.detailedMaps[indexPath.row]
        performSegue(withIdentifier: MMTSegue.DisplayDetailedMap, sender: self)
    }

    // MARK: Actions

    @IBAction func unwindToListOfDetailedMaps(_ unwindSegue: UIStoryboardSegue)
    {        
    }
}
