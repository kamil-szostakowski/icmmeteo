//
//  MMTLocalization.swift
//  MeteoUIKit
//
//  Created by szostakowskik on 15/02/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

public func MMTLocalizedString(_ string: String) -> String
{
    return NSLocalizedString(string, comment: "")
}

public func MMTLocalizedStringWithFormat(_ format: String, _ arguments: CVarArg...) -> String
{
    return String(format: NSLocalizedString(format, comment: ""), arguments: arguments)
}
