//
//  MMTTabBarController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 17.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTTabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initItemAtIndex(0, withStore: MMTUmModelStore(date: NSDate()))
        initItemAtIndex(1, withStore: MMTCoampsModelStore(date: NSDate()))
        
        let attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 10)!,
        ]

        UITabBarItem.appearance().setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, forState: UIControlState.Selected)
    }
    
    // MARK: Helper methods
    
    private func initItemAtIndex(index: Int, withStore store: MMTGridClimateModelStore)
    {
        let item = tabBar.items?[index] as! UITabBarItem
        let controller = viewControllers?[index] as! MMTCitiesListController
        let icon = UIImage(named: store.meteorogramId.rawValue)
        
        controller.meteorogramStore = store
//        controller.view.tintColor = store.meteorogramId.tintColor
        
        item.title = store.meteorogramId.description
        item.image = icon
        item.selectedImage = icon
    }
}