//
//  UIImageView.swift
//  MeteoWidget
//
//  Created by szostakowskik on 05.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit

extension UIImageView: MMTUpdatableView
{
    func updated(with image: UIImage?) -> UIImageView
    {
        self.image = image
        return self
    }
}
