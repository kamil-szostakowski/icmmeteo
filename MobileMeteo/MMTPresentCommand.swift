//
//  MMTDisplayCommand.swift
//  MobileMeteo
//
//  Created by szostakowskik on 14.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTPresentCommand<T: UIViewController>
{
    fileprivate var tabbar: UITabBarController
    
    fileprivate var targetViewController: T? {
        return tabbar.viewControllers?.first { $0 as? T != nil } as? T
    }
    
    init(tabbar: UITabBarController)
    {
        self.tabbar = tabbar
    }
    
    fileprivate func prepare(completion: @escaping (() -> Void))
    {
        guard let targetController = targetViewController else {
            return
        }
        
        guard let index = tabbar.viewControllers?.index(of: targetController) else {
            return
        }
        
        tabbar.selectedIndex = index
        
        if targetController.presentedViewController != nil {
            targetController.dismiss(animated: false, completion: completion)
        }
        else {
            completion()
        }
    }
}

extension MMTPresentCommand where T == MMTCitiesListController
{
    func present(city: MMTCityProt)
    {
        prepare {
            self.targetViewController?.selectedCity = city
            self.targetViewController?.perform(segue: .DisplayMeteorogram, sender: self.tabbar)
        }
    }
}

extension MMTPresentCommand where T == MMTDetailedMapsListController
{
    func present(model: MMTClimateModel, map: MMTDetailedMapType)
    {
        prepare {
            guard let detailedMap = model.detailedMap(ofType: map) else {
                return
            }
            
            self.targetViewController?.selectedClimateModel = model
            self.targetViewController?.selectedDetailedMap = detailedMap
            self.targetViewController?.perform(segue: .DisplayDetailedMap, sender: self.tabbar)
        }
    }
}
