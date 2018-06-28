//
//  TodayViewController.swift
//  MeteoWidget
//
//  Created by szostakowskik on 22.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import CoreLocation
import MeteoModel
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding
{
    // MARK: Properties
    @IBOutlet weak var meteorogramImage: UIImageView!
    @IBOutlet weak var hederHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    
    private var locationService: MMTLocationService!
    private var modelController: MMTTodayModelController!
    
    // MARK: Lefecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupModelController()
        setupWidgetDisplayMode()
        
        // TODO: UI for disabled location services
        // TODO: UI for meteorogram fetch error
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        headerView.isHidden = activeDisplayMode == .expanded
        preferredContentSize = maxSize
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
    {
        modelController.onUpdate(location: locationService.currentLocation) {
            completionHandler(NCUpdateResult(updateStatus: $0))
        }
    }
}

extension TodayViewController
{
    // MARK: Setup methods
    fileprivate func setupModelController()
    {
        locationService = MMTCoreLocationService(locationManager: CLLocationManager())
        modelController = MMTTodayModelController(model: MMTUmClimateModel())
        modelController.delegate = self
    }
    
    fileprivate func setupWidgetDisplayMode()
    {
        guard let context = extensionContext else {
            return
        }
        
        hederHeightConstraint.constant = context.widgetMaximumSize(for: .compact).height
        context.widgetLargestAvailableDisplayMode = .expanded
    }
}

extension TodayViewController: MMTModelControllerDelegate
{
    func onModelUpdate(_ controller: MMTModelController)
    {
        guard let result = modelController.updateResult else {
            return
        }
        
        guard case let .success(meteorogram) = result else {
            return
        }
        
        meteorogramImage.image = meteorogram.image
        print("Model updated")
    }
    
    // MARK: Data update methods
    
}
