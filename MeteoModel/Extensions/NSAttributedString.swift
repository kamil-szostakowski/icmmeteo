//
//  NSAttributedString.swift
//  MobileMeteo
//
//  Created by szostakowskik on 15.06.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

extension NSAttributedString
{
    func formattedAsComment() -> NSAttributedString
    {
        let range = NSRange(location: 0, length: length)
        let font = UIFont(name: "HelveticaNeue-Light", size: 16)!
        
        let
        paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        
        let
        formattedContent = NSMutableAttributedString(attributedString: self)
        formattedContent.addAttribute(.font, value: font, range: range)
        formattedContent.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        return NSAttributedString(attributedString: formattedContent)
    }
}
