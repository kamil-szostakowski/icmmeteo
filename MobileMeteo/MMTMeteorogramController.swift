//
//  MMTMeteorogramController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class MMTMeteorogramController: UIViewController
{
    // MARK: Outlets
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var meteorogramImage: UIImageView!

    // MARK: Properties
    
    var meteorogramTitle: String?
    var cityName: String?
    var cityLocation: CLLocation?

    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationBar.topItem!.prompt = meteorogramTitle
        navigationBar.topItem!.title = cityName
        
        if let location = cityLocation {
            let query = MMTMeteorogramQuery(location: location, date: NSDate())
            
            MMTMeteorogramStore().getMeteorogramWithQuery(query, completion: {(data: NSData?, error: NSError?) in
                
                if let meteorogram = data {
                    self.meteorogramImage.image = UIImage(data: meteorogram)
                }
            })
        }
    }

    // MARK: Actions

    @IBAction func onCloseBtnTouchAction(sender: UIBarButtonItem)
    {        
        performSegueWithIdentifier(Segue.UnwindToListOfCities, sender: self)
    }
}