//
//  MMTDetailedMapPreviewShortcut.swift
//  MobileMeteo
//
//  Created by szostakowskik on 15.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import MeteoModel

class MMTDetailedMapShortcut : MMTShortcut
{        
    let climateModel: MMTClimateModel
    let detailedMap: MMTDetailedMapType
    
    var identifier: String {
        return "map-\(climateModel.type.rawValue)-\(detailedMap.rawValue)"
    }
    
    init(model: MMTClimateModel, map: MMTDetailedMapType)
    {
        self.climateModel = model
        self.detailedMap = map
    }
    
    func execute(using tabbar: MMTTabBarController, completion: (() -> Void)?)
    {
        guard let targetVC = (tabbar.viewControllers?.first { $0 as? MMTDetailedMapsListController != nil } as? MMTDetailedMapsListController) else {
            completion?()
            return
        }
        
        prepare(tabbar: tabbar, target: targetVC)
        {
            targetVC.selectedClimateModel = self.climateModel
            targetVC.selectedDetailedMap = self.climateModel.detailedMap(ofType: self.detailedMap)
            targetVC.perform(segue: .DisplayDetailedMap, sender: tabbar)
            
            completion?()
        }
    }
}
