//
//  MMTTabBarController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 17.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import Foundation
import UIKit

class MMTTabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
                        
        itemAtIndex(0).title = "Model UM"
        modelControllerAtIndex(0).modelType = MMTModelType.UM
        
        itemAtIndex(1).title = "Model COAMPS"
        modelControllerAtIndex(1).modelType = MMTModelType.COAMPS        
    }
    
    // MARK: Helper methods
    
    func itemAtIndex(index: Int) -> UITabBarItem
    {
        return tabBar.items?[index] as! UITabBarItem
    }
    
    func modelControllerAtIndex(index: Int) -> MMTCitiesListController
    {
        return viewControllers?[index] as! MMTCitiesListController
    }
}