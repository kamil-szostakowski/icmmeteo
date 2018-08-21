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

extension NSMutableAttributedString
{
    var fullRange: NSRange
    {
        return NSRange(location: 0, length: length)
    }
    
    func addAttribute(_ name: NSAttributedStringKey, value: Any)
    {
        addAttribute(name, value: value, range: fullRange)
    }
    
    func set(url: String, for text: String)
    {
        let range = mutableString.range(of: text)
        
        if range.location != NSNotFound {
            addAttribute(.link, value: url, range: range)
            addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        }
    }
}

extension NSMutableAttributedString
{
    convenience init(textView: UITextView)
    {
        self.init(string: textView.text)
        addAttribute(.font, value: textView.font!)
    }
}
