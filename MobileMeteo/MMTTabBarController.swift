//
//  MMTTabBarController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 17.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTTabBarController: UITabBarController, UITabBarControllerDelegate, MMTActivityIndicating
{
    // MARK: Properties
    var activityIndicator: MMTActivityIndicator!
    
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()

        delegate = self
        
        let attributes = [NSAttributedString.Key.font: MMTAppearance.fontWithSize(10)]

        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: UIControl.State())
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: UIControl.State.selected)
        UITabBar.appearance().tintColor = MMTAppearance.textColor
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {        
        return .portrait
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
