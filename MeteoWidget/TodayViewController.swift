//
//  TodayViewController.swift
//  MeteoWidget
//
//  Created by szostakowskik on 22.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import CoreLocation
import MeteoModel
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding
{
    @IBOutlet weak var meteorogramImage: UIImageView!
    private var locationService: MMTLocationService!
    private var forecastService: MMTForecastService!
    private var meteorogramStore: MMTMeteorogramStore!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationService = MMTCoreLocationService(locationManager: CLLocationManager())
        forecastService = MMTForecastService(model: MMTUmClimateModel())
        meteorogramStore = MMTMeteorogramStore(model: MMTUmClimateModel())
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        preferredContentSize = maxSize
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void))
    {
        forecastService.update(for: locationService.currentLocation) { status in
            
            guard let city = self.forecastService.currentCity else {
                completionHandler(.failed)
                return
            }
            
            self.meteorogramStore.meteorogram(for: city) {
                
                guard case let .success(meteorogram) = $0 else {
                    return
                }
                print("meteorogram updated")
                self.meteorogramImage.image = meteorogram.image
                completionHandler(NCUpdateResult.newData)
            }
        }
    }
    
}
