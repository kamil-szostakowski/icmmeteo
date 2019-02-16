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

class MMTTodayViewController: UIViewController, NCWidgetProviding
{
    // MARK: Properties
    private var modelController: MMTTodayModelController!
    private var factory: MMTExtensionViewModeFactory!
    private var locationService: MMTCoreLocationService!
    private weak var currentView: UIView?
    
    // MARK: Lefecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupModelController()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        preferredContentSize = maxSize
        
        if currentView != nil {
            onModelUpdate(modelController)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
    {
        modelController.onUpdate {
            completionHandler(NCUpdateResult(updateStatus: $0))
        }
    }
}

extension MMTTodayViewController
{
    // MARK: Setup methods
    fileprivate func setupModelController()
    {
        let forecastService = MMTMeteorogramForecastService(model: MMTUmClimateModel())
        
        locationService = MMTCoreLocationService(CLLocationManager())
        factory = MMTExtensionViewModeFactory()
        modelController = MMTTodayModelController(forecastService, locationService)
        modelController.delegate = self
    }
}

extension MMTTodayViewController: MMTModelControllerDelegate
{
    // MARK: Data update methods
    func onModelUpdate(_ controller: MMTModelController)
    {
        guard let context = extensionContext else {
            return
        }
        
        let viewMode = factory.build(for: modelController, with: context)
        context.widgetLargestAvailableDisplayMode = modelController.meteorogram != nil ? .expanded : .compact
        
        replaceCurrentView(with: viewMode.0)
        analytics?.sendUserActionReport(.Widget, action: viewMode.1)
    }
    
    fileprivate func replaceCurrentView(with newView: UIView)
    {
        currentView?.removeFromSuperview()
        view.addFillingSubview(newView)
        currentView = newView
    }
}
