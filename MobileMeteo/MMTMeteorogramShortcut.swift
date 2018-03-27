//
//  MMTMeteorogramPreviewShortcut.swift
//  MobileMeteo
//
//  Created by szostakowskik on 15.12.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import CoreLocation
import MeteoModel

class MMTMeteorogramShortcut : MMTShortcut
{        
    var location: CLLocation
    let name: String
    let region: String
    let climateModelType: String
    
    var identifier: String {
        return "meteorogram-\(climateModelType)-\(location.coordinate.latitude):\(location.coordinate.longitude)"
    }
    
    init(model: MMTClimateModel, city: MMTCityProt)
    {
        self.name = city.name
        self.region = city.region
        self.location = city.location
        self.climateModelType = model.type.rawValue
    }
        
    func execute(using tabbar: MMTTabBarController, completion: MMTCompletion?)
    {
        tabbar.displayActivityIndicator(in: tabbar.view, message: nil)
        
        MMTCoreDataCitiesStore().city(for: location) { (city, error) in
            
            tabbar.hideActivityIndicator()
            
            guard let selectedCity = city, error == nil else {
                tabbar.present(UIAlertController.alertForMMTError(error!), animated: true, completion: nil)
                completion?()
                return
            }
            
            guard let targetVC = (tabbar.viewControllers?.first { $0 as? MMTCitiesListController != nil } as? MMTCitiesListController) else {
                completion?()
                return
            }
            
            self.prepare(tabbar: tabbar, target: targetVC)
            {
                targetVC.selectedCity = selectedCity
                targetVC.perform(segue: .DisplayMeteorogram, sender: tabbar)
                completion?()
            }
        }
    }
}
