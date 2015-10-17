//
//  MMTWamModelCollectionViewLayout.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 24.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

@objc protocol MMTCollectionViewDelegateWamLayout: UICollectionViewDelegate
{
    optional func collectionView(collectionView: UICollectionView, itemSizeForLayout collectionViewLayout: UICollectionViewLayout) -> CGSize
}

class MMTCollectionViewWamLayout: UICollectionViewLayout
{
    private typealias MMTLayoutIndex = [NSIndexPath: UICollectionViewLayoutAttributes]
    
    private var cellLayoutAttributes = MMTLayoutIndex()
    private var headerLayoutAttributes = MMTLayoutIndex()
    
    private var delegate: MMTCollectionViewDelegateWamLayout? {
        return collectionView?.delegate as? MMTCollectionViewDelegateWamLayout
    }
    
    var itemSize: CGSize! = CGSizeMake(130, 140)
    var headerViewWidth: NSNumber! = 50
    var itemSpacing: NSNumber! = 2
    var sectionSpacing: NSNumber! = 2
    
    static let headerViewIdentifier = "MMTWamLayoutHeaderViewIdentifier"
    
    // MARK: UICollectionViewLayout setup methods
    
    override func prepareLayout()
    {
        if collectionView!.numberOfSections() == 0 {
            return
        }
        
        itemSize = calculateItemSize()
        cellLayoutAttributes = MMTLayoutIndex()
        headerLayoutAttributes = MMTLayoutIndex()        

        for section in 0..<collectionView!.numberOfSections() {
            for item in 0..<collectionView!.numberOfItemsInSection(section) {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                cellLayoutAttributes[indexPath] = createCellLayoutAttributesForIndexPath(indexPath)
            }
            
            let indexPath = NSIndexPath(forItem: 0, inSection: section)
            headerLayoutAttributes[indexPath] = createHeaderLayoutAttributesForIndexPath(indexPath)
        }
        return
    }
    
    private func calculateItemSize() -> CGSize
    {
        if let size = delegate?.collectionView?(collectionView!, itemSizeForLayout: self) {
            return size
        }
        return itemSize
    }
    
    private func createCellLayoutAttributesForIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes
    {
        let
        itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        itemAttributes.frame = calculateFrameForCellAtIndexPath(indexPath)
        
        return itemAttributes
    }
    
    private func calculateFrameForCellAtIndexPath(indexPath: NSIndexPath) -> CGRect
    {
        let itemWidth = itemSize.width+CGFloat(itemSpacing)
        let itemHeight = itemSize.height+CGFloat(sectionSpacing)
        
        let x = CGFloat(indexPath.item)*itemWidth+CGFloat(headerViewWidth)+CGFloat(itemSpacing)
        let y = CGFloat(indexPath.section)*itemHeight
        
        return CGRectMake(x, y, itemSize.width, itemSize.height)
    }
    
    private func createHeaderLayoutAttributesForIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes
    {
        let identifier = MMTCollectionViewWamLayout.headerViewIdentifier
        
        let
        headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: identifier, withIndexPath: indexPath)
        headerAttributes.frame = calculateFrameForHeaderAtIndexPath(indexPath)
        
        return headerAttributes
    }
    
    private func calculateFrameForHeaderAtIndexPath(indexPath: NSIndexPath) -> CGRect
    {
        let headerHeight = CGFloat(sectionSpacing)+itemSize.height
        let y = CGFloat(indexPath.section)*headerHeight
        
        return CGRectMake(0, y, CGFloat(headerViewWidth), itemSize.height)
    }
    
    // MARK: UICollectionViewLayout methods
    
    override func collectionViewContentSize() -> CGSize
    {
        let itemWidth = Int(itemSize.width)+Int(itemSpacing)
        let itemHeight = Int(itemSize.height)+Int(sectionSpacing)
        let height = collectionView!.numberOfSections()*itemHeight-Int(sectionSpacing)
        var width = 0
        
        for section in 0..<collectionView!.numberOfSections()
        {
            let sectionWidth = collectionView!.numberOfItemsInSection(section)*itemWidth
            
            if sectionWidth > width {
                width = sectionWidth
            }
        }

        return CGSizeMake(CGFloat(width)+CGFloat(headerViewWidth)+CGFloat(itemSpacing), CGFloat(height))
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        let cellAttributes = getElementsInRect(rect, fromIndex: cellLayoutAttributes)
        let headerAttributes = getElementsInRect(rect, fromIndex: headerLayoutAttributes)

        return cellAttributes+headerAttributes
    }
    
    private func getElementsInRect(rect: CGRect, fromIndex index: MMTLayoutIndex) -> [UICollectionViewLayoutAttributes]
    {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        for itemAttributes in index.values
        {
            if CGRectIntersectsRect(rect, itemAttributes.frame) {
                attributes.append(itemAttributes)
            }
        }
        
        return attributes;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        return cellLayoutAttributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        return headerLayoutAttributes[indexPath]
    }    
}