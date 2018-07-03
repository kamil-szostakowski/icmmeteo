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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var hederHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var meteorogramImage: UIImageView!
    
    private var modelController: MMTTodayModelController!
    
    private var activeHeader: UIView {
        return modelController.locationServicesEnabled ? headerView : errorView
    }
    
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
        activeHeader.isHidden = activeDisplayMode == .expanded
        meteorogramImage.isHidden = activeDisplayMode == .compact
        preferredContentSize = maxSize
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
    {
        modelController.onUpdate {
            completionHandler(NCUpdateResult(updateStatus: $0))
        }
    }
}

extension TodayViewController
{
    // MARK: Setup methods
    fileprivate func setupModelController()
    {
        let locationService = MMTCoreLocationService(locationManager: CLLocationManager())
        let forecastService = MMTMeteorogramForecastService(model: MMTUmClimateModel())
        
        modelController = MMTTodayModelController(forecastService, locationService)
        modelController.delegate = self
    }
    
    fileprivate func setupWidgetDisplayMode()
    {
        guard let context = extensionContext else {
            return
        }
        
        hederHeightConstraint.constant = context.widgetMaximumSize(for: .compact).height
        errorViewHeightConstraint.constant = context.widgetMaximumSize(for: .compact).height
    }
}

extension TodayViewController: MMTModelControllerDelegate
{
    // MARK: Data update methods
    func onModelUpdate(_ controller: MMTModelController)
    {
        if modelController.locationServicesEnabled {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            errorView.isHidden = true
            headerView.isHidden = false
        } else {
            extensionContext?.widgetLargestAvailableDisplayMode = .compact
            errorView.isHidden = true
            headerView.isHidden = false
        }
        
        guard let meteorogram = modelController.meteorogram else {
            return
        }
        
        meteorogramImage.image = meteorogram.image
        print("Model updated")
    }
}
