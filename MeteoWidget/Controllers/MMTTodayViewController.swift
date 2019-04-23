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
    private var factory: MMTFactory = MMTDefaultFactory()
    private var viewFactory = MMTExtensionViewModeFactory()
    private weak var currentView: UIView?
    
    // MARK: Lefecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupModelController()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if activeDisplayMode == .expanded
        {
            let size = CGSize(meteorogram: .UM)!
            let scale = maxSize.width / size.width
            preferredContentSize = CGSize(width: maxSize.width, height: size.height*scale)
        } else {
            preferredContentSize = maxSize
        }
        
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
        modelController = factory.createTodayModelController(.widget)
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
        
        let viewMode = viewFactory.build(for: modelController, with: context)
        
        switch modelController.updateResult {
            case .success(_): context.widgetLargestAvailableDisplayMode = .expanded
            case .failure(_): context.widgetLargestAvailableDisplayMode = .compact
        }
        
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
