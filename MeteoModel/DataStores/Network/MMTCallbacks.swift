//
//  MMTCallbacks.swift
//  MeteoModel
//
//  Created by szostakowskik on 19.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit

public typealias MMTFetchMeteorogramCompletion = (_ image: UIImage?, _ error: MMTError?) -> Void
public typealias MMTFetchForecastStartDateCompletion = (_ date: Date?, _ error: MMTError?) -> Void
public typealias MMTFetchHTMLCompletion = (_ html: String?, _ error: MMTError?) -> Void
public typealias MMTFetchMeteorogramsCompletion = (_ image: UIImage?, _ date: Date?, _ error: MMTError?, _ finish: Bool) -> Void
public typealias MMTFetchCommentCompletion = (_ comment: NSAttributedString?, _ error: MMTError?) -> Void
