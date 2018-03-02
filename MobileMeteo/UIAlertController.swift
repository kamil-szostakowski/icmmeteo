//
//  UIAlertController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 13.01.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import MeteoModel

extension UIAlertController
{
    class func alertForMMTError(_ error: MMTError) -> UIAlertController
    {
        return self.alertForMMTError(error, completion: nil)
    }
    
    class func alertForMMTError(_ error: MMTError, completion: ((UIAlertAction) -> Void)?) -> UIAlertController
    {
        let closeAction = UIAlertAction(title: MMTLocalizedString("label.close"), style: .cancel, handler: completion)
        
        let
        alert = UIAlertController(title: "", message: MMTLocalizedString("error.\(error.rawValue)"), preferredStyle: .alert)
        alert.addAction(closeAction)
        
        return alert
    }
}
