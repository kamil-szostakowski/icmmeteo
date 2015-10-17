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
    
    private func setupView()
    {
        backgroundColor = MMTAppearance.lightGrayBackgroundColor
    }
    
    // Mark: Overrides
    
    override func prepareForReuse()
    {
        categoryTitle = ""
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect)
    {
        let
        style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.lineBreakMode = .ByWordWrapping
        style.alignment = .Center
        
        let textAttributes = [
            NSFontAttributeName: MMTAppearance.fontWithSize(12),
            NSParagraphStyleAttributeName: style
        ]
        
        let textSize = categoryTitle.sizeWithAttributes(textAttributes)        
        let drawingArea = calculateDrawingAreaInRect(rect, textSize: textSize)
        let context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)
        CGContextTranslateCTM(context, 0, bounds.height)
        CGContextRotateCTM(context, CGFloat(-M_PI_2));
        
        categoryTitle.drawInRect(drawingArea, withAttributes: textAttributes)

        CGContextRestoreGState(context)
    }
    
    private func calculateDrawingAreaInRect(rect: CGRect, textSize: CGSize) -> CGRect
    {
        let numberOfLines = ceil(textSize.width/(rect.size.height-10))
        let xOffset = abs(bounds.width-textSize.height*numberOfLines)/2
        
        return CGRectMake(5, xOffset, bounds.height-10, bounds.width)
    }
}