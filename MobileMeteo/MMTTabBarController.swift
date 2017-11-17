//
//  MMTTabBarController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 17.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTTabBarController: UITabBarController, UITabBarControllerDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        delegate = self
        
        let attributes = [NSAttributedStringKey.font: MMTAppearance.fontWithSize(10)]

        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: UIControlState.selected)
        UITabBar.appearance().tintColor = MMTAppearance.textColor
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {        
        return .portrait
    }
    
    // MARK: Interface methods
    
    func presentMeteorogram(for city: MMTCityProt)
    {
        guard let citiesListController = viewControllers?.first as? MMTCitiesListController else {
            return
        }
        
        selectedIndex = 0
        
        if presentedViewController != nil {
            dismiss(animated: false, completion: nil)
        }
        
        citiesListController.selectedCity = city
        citiesListController.perform(segue: .DisplayMeteorogram, sender: self)
    }
    
    // MARK: UITabBarControllerDelegate methods
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        guard let index =  tabBarController.viewControllers?.index(of: viewController) else {
            return
        }

        let tabBarItems = tabBar.layer.sublayers!
            .filter(){ $0.frame.size.width < tabBar.frame.size.width }
            .sorted(){ $0.frame.origin.x < $1.frame.origin.x }
            .map() { $0.sublayers!.max(){ $0.frame.size.height < $1.frame.size.height }!
        }
            
        tabBarItems[index].add(.defaultScaleAnimation(), forKey: "basic")
    }    
}
