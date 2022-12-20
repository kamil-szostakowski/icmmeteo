//
//  UIBackgroundFetchResult.swift
//  MobileMeteo
//
//  Created by szostakowskik on 27.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import MeteoModel

extension UIBackgroundFetchResult
{
    init(updateStatus: MMTUpdateResult)
    {
        switch updateStatus {
        case .noData: self = .noData
        case .newData: self = .newData
        case.failed: self = .failed
        }
    }
}
