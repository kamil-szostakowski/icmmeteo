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
        
        initItemAtIndex(0, name: "Model UM", model: MMTUmClimateModel())
        initItemAtIndex(1, name: "Model COAMPS", model: MMTCoampsClimateModel())

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
    
    func presentMeteorogramUmForCity(_ city: MMTCityProt)
    {
        guard let umController = viewControllers?.first as? MMTCitiesListController else {
            return
        }
        
        if presentedViewController != nil {
            dismiss(animated: false, completion: nil)
        }
        
        umController.selectedCity = city
        
        if selectedIndex == 0 {
            umController.perform(segue: .DisplayMeteorogram, sender: self)
        }
        
        selectedIndex = 0
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
            .map() {
                $0.sublayers!.max(){ $0.frame.size.height < $1.frame.size.height }!
        }
            
        tabBarItems[index].add(CAAnimation.defaultScaleAnimation(), forKey: "basic")
    }
    
    // MARK: Helper methods
    
    private func initItemAtIndex(_ index: Int, name: String, model: MMTClimateModel)
    {
        let iconName = name.lowercased().replacingOccurrences(of: " ", with: "-")
        let icon = UIImage(named: iconName)
        
        let
        controller = viewControllers?[index] as! MMTCitiesListController
        controller.climateModel = model
        
        let
        item = tabBar.items![index]
        item.title = name
        item.image = icon
        item.selectedImage = icon
    }
}
