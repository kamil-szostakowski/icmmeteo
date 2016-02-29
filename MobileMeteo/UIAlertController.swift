//
//  UIAlertController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 13.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

extension UIAlertController
{
    class func alertForMMTError(error: MMTError) -> UIAlertController
    {
        return self.alertForMMTError(error, completion: nil)
    }
    
    class func alertForMMTError(error: MMTError, completion: ((UIAlertAction) -> Void)?) -> UIAlertController
    {
        let closeAction = UIAlertAction(title: "zamknij", style: .Cancel, handler: completion)
        
        let
        alert = UIAlertController(title: "", message: error.description, preferredStyle: .Alert)
        alert.addAction(closeAction)
        
        return alert
    }
}