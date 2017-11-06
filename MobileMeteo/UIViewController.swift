//
//  UIViewController.swift
//  MobileMeteo
//
//  Created by szostakowskik on 06.11.2017.
//  Copyright © 2017 Kamil Szostakowski. All rights reserved.
//

import Foundation

enum MMTSegue: String
{
    case UnwindToListOfCities
    case UnwindToListOfDetailedMaps
    case UnwindToWamModel
    case DisplayMeteorogram
    case DisplayWamSettings
    case DisplayWamCategoryPreview
    case DisplayMapScreen
    case DisplayDetailedMapsList
    case DisplayDetailedMap
}

extension UIViewController
{
    func perform(segue: MMTSegue, sender: Any?)
    {
        performSegue(withIdentifier: segue.rawValue, sender: sender)
    }
}
