//
//  MMTNavigator.swift
//  MobileMeteo
//
//  Created by szostakowskik on 01.08.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import MeteoModel

class MMTNavigator
{
    // MARK: Destinations
    enum MMTDestination
    {
        case onboarding(UInt)
        case meteorogramHere(MMTClimateModel)
        case meteorogram(MMTClimateModel, MMTCityProt)
        case detailedMap(MMTClimateModel, MMTDetailedMapType)
    }
    
    // MARK: Properties
    private var locationService: MMTLocationService
    private var tabbar: MMTTabBarController
    private var defaults: UserDefaults
    
    // MARK: Initializers
    init(
        _ tabbar: MMTTabBarController,
        _ locationService: MMTLocationService,
        _ userDefaults: UserDefaults = .standard)
    {
        self.tabbar = tabbar
        self.locationService = locationService
        self.defaults = userDefaults
    }
    
    // MARK: Interface methods
    func navigate(to destination: MMTDestination, completion: @escaping () -> Void)
    {
        switch destination {
            case let .onboarding(seq): navigateToOnboarding(seq, completion)
            case let .meteorogramHere(model): navigateToMeteorogramHere(model, completion)
            case let .meteorogram(model, city): navigateToMeteorogram(city, model, completion)
            case let .detailedMap(model, map): navigateToDetailedMap(map, model, completion)
        }
    }
}

extension MMTNavigator
{
    // MARK: Helper methods
    fileprivate func navigateToOnboarding(_ sequence: UInt, _ completion: @escaping () -> Void)
    {
        if defaults.onboardingSequenceNumber < sequence {
            tabbar.perform(segue: .DisplayOnboarding, sender: self.tabbar)
            defaults.onboardingSequenceNumber = sequence
        }
        completion()
    }
    
    fileprivate func navigateToMeteorogramHere(_ model: MMTClimateModel, _ completion: @escaping () -> Void)
    {
        tabbar.displayActivityIndicator(in: tabbar.view, message: nil)
        locationService.requestLocation().observe {
            self.tabbar.hideActivityIndicator()
            
            if case let .failure(error) = $0 {
                self.tabbar.present(UIAlertController.alertForMMTError(error), animated: true, completion: nil)
                completion()
                return
            }
            
            if case let .success(city) = $0 {
                self.navigateToMeteorogram(city, model) {
                    self.tabbar.hideActivityIndicator()
                    completion()
                }
            }
        }
    }
    
    fileprivate func navigateToMeteorogram(_ city: MMTCityProt, _ model: MMTClimateModel, _ completion: @escaping () -> Void)
    {
        guard let targetVC = targetController(of: MMTCitiesListController.self) else {
            completion()
            return
        }
        
        MMTCoreDataCitiesStore().cities(matching: city.name) {
            guard let aCity = $0.first else { completion(); return }
         
            self.prepare(targetVC) {
                targetVC.selectedCity = aCity
                targetVC.perform(segue: .DisplayMeteorogram, sender: self.tabbar)
                completion()
            }
        }
    }
    
    fileprivate func navigateToDetailedMap(_ map: MMTDetailedMapType, _ model: MMTClimateModel, _ completion: @escaping () -> Void)
    {
        guard let targetVC = targetController(of: MMTDetailedMapsListController.self) else {
            completion()
            return
        }
        
        prepare(targetVC) {
            targetVC.selectedClimateModel = model
            targetVC.selectedDetailedMap = model.detailedMap(ofType: map)
            targetVC.perform(segue: .DisplayDetailedMap, sender: self.tabbar)
            completion()
        }
    }
    
    fileprivate func prepare(_ target: UIViewController, completion: @escaping () -> Void)
    {
        tabbar.selectedIndex = (tabbar.viewControllers?.firstIndex(of: target))!
        
        guard target.presentedViewController == nil else {
            target.dismiss(animated: false, completion: completion)
            return
        }
        
        completion()
    }
    
    fileprivate func targetController<T>(of type: T.Type) -> T?
    {
        return tabbar.viewControllers?.first { $0 as? T != nil } as? T
    }
}
