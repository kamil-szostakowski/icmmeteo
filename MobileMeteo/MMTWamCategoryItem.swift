//
//  MMTWamCategoryItem.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTWamCategoryItem: UICollectionViewCell
{
    @IBOutlet var map: UIImageView!
    @IBOutlet var title: UILabel!
    
    override func prepareForReuse()
    {
        map.image = nil
        title.text = ""
    }
}