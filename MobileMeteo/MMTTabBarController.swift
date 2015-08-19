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
        
        initItemAtIndex(0, withStore: MMTUmMeteorogramStore())
        initItemAtIndex(1, withStore: MMTCoampsMeteorogramStore())
    }
    
    // MARK: Helper methods
    
    private func initItemAtIndex(index: Int, withStore store: MMTMeteorogramStore)
    {
        let item = tabBar.items?[index] as! UITabBarItem
        let controller = viewControllers?[index] as! MMTCitiesListController
        
        item.title = store.meteorogramTitle
        controller.meteorogramStore = store
    }
}