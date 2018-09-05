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
    private var dataSource: MMTTodayExtensionDataSource!
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
        dataSource = MMTTodayExtensionDataSource()
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
        
        context.widgetLargestAvailableDisplayMode = dataSource.todayExtension(context, displayModeFor: modelController)
        replaceCurrentView(with: dataSource.todayExtension(context, viewFor: modelController))        
    }
    
    fileprivate func replaceCurrentView(with newView: UIView)
    {
        currentView?.removeFromSuperview()
        view.addFillingSubview(newView)
        currentView = newView
    }
}
