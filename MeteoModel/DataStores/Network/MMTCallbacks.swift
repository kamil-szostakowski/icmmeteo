//
//  MMTCallbacks.swift
//  MeteoModel
//
//  Created by szostakowskik on 19.03.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit

public typealias MMTFetchHTMLCompletion = (_ html: String?, _ error: MMTError?) -> Void
public typealias MMTFetchCommentCompletion = (_ comment: NSAttributedString?, _ error: MMTError?) -> Void
