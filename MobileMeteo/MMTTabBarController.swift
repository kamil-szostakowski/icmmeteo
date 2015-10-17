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

        let attributes = [NSFontAttributeName: MMTAppearance.fontWithSize(10)]

        UITabBarItem.appearance().setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, forState: UIControlState.Selected)
        UITabBar.appearance().tintColor = MMTAppearance.textColor
    }
    
    // MARK: Helper methods
    
    private func initItemAtIndex(index: Int, withStore store: MMTGridClimateModelStore)
    {
        let item = tabBar.items![index]
        let controller = viewControllers?[index] as! MMTCitiesListController
        let icon = UIImage(named: store.meteorogramId.rawValue)
        
        controller.meteorogramStore = store
        
        item.title = store.meteorogramId.description
        item.image = icon
        item.selectedImage = icon
    }
}