//
//  MMTDetailedMapPreviewController.swift
//  MobileMeteo
//
//  Created by Kamil on 02.12.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTDetailedMapPreviewController: UIViewController
{
    // MARK: Properties
    
    @IBOutlet weak var detailedMapImage: UIImageView!
    
    private var meteorogramStore: MMTGridClimateModelStore!
    private var moments: [MMTWamMoment]!
    private var map: MMTDetailedMap!
    private var currentMomentIndex = 0;
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        meteorogramStore = MMTUmModelStore(date: Date())
        map = meteorogramStore.detailedMaps[3]
        moments = meteorogramStore.getForecastMomentsForMap(map)
        
        fetchMeteorogram(for: moments[currentMomentIndex].date)
    }
    
    // MARK: Actions
    
    @IBAction func nextButtonDidTap(_ sender: UIButton)
    {
        if currentMomentIndex+1 < moments.count
        {
            currentMomentIndex += 1
            fetchMeteorogram(for: moments[currentMomentIndex].date)
        }
        else
        {
            NSLog("All moments fetched")
        }
    }
    
    // MARK: Helper methods
    
    private func fetchMeteorogram(for date: Date)
    {
        meteorogramStore.getMeteorogramForMap(map, moment: date) {
            [unowned self] (data: Data?, error: MMTError?) in
            
            guard let imageData = data else {
                NSLog("Image fetch failure 1")
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                NSLog("Image fetch failure 2")
                return
            }
            
            self.detailedMapImage.image = image
        }
    }
}
