//
//  MMTWamHeaderView.swift
//  MobileMeteo
//
//  Created by Kamil on 25.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreText

class MMTWamHeaderView: UICollectionReusableView
{
    var categoryTitle: NSString = ""
    
    // MARK: Initializers
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: Setup
    
    fileprivate func setupView()
    {
        backgroundColor = MMTAppearance.lightGrayBackgroundColor
        isAccessibilityElement = true
        accessibilityIdentifier = "MMTWamHeaderView"
    }
    
    // Mark: Overrides
    
    override func prepareForReuse()
    {
        categoryTitle = ""
        accessibilityLabel = ""
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect)
    {
        accessibilityLabel = String(categoryTitle)
        
        let
        style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        
        let textAttributes = [
            NSFontAttributeName: MMTAppearance.fontWithSize(12),
            NSParagraphStyleAttributeName: style
        ]
        
        let textSize = categoryTitle.size(attributes: textAttributes)        
        let drawingArea = calculateDrawingAreaInRect(rect, textSize: textSize)
        let context = UIGraphicsGetCurrentContext()

        context?.saveGState()
        context?.translateBy(x: 0, y: bounds.height)
        context?.rotate(by: CGFloat(-M_PI_2));
        
        categoryTitle.draw(in: drawingArea, withAttributes: textAttributes)

        context?.restoreGState()
    }
    
    fileprivate func calculateDrawingAreaInRect(_ rect: CGRect, textSize: CGSize) -> CGRect
    {
        let numberOfLines = ceil(textSize.width/(rect.size.height-10))
        let xOffset = abs(bounds.width-textSize.height*numberOfLines)/2
        
        return CGRect(x: 5, y: xOffset, width: bounds.height-10, height: bounds.width)
    }
}
