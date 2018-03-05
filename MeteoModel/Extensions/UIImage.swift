//
//  UIImage.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 19/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

extension UIImage
{
    convenience init?(_ data: Data?)
    {
        guard let imageData = data else {
            return nil
        }

        self.init(data: imageData)
    }
}
