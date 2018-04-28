//
//  InterfaceController.swift
//  MeteoWatch Extension
//
//  Created by szostakowskik on 28.04.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import WatchKit
import Foundation
import MeteoModelWatch

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        MMTCoreDataCitiesStore().all {
            print("Cities: \($0)")
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
