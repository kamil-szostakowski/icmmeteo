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
    @objc optional func collectionView(_ collectionView: UICollectionView, itemSizeForLayout collectionViewLayout: UICollectionViewLayout) -> CGSize
}

class MMTCollectionViewWamLayout: UICollectionViewLayout
{
    fileprivate typealias MMTLayoutIndex = [IndexPath: UICollectionViewLayoutAttributes]
    
    fileprivate var cellLayoutAttributes = MMTLayoutIndex()
    fileprivate var headerLayoutAttributes = MMTLayoutIndex()
    
    fileprivate var delegate: MMTCollectionViewDelegateWamLayout? {
        return collectionView?.delegate as? MMTCollectionViewDelegateWamLayout
    }
    
    var itemSize: CGSize! = CGSize(width: 130, height: 140)
    var headerViewWidth: NSNumber! = 50
    var itemSpacing: NSNumber! = 2
    var sectionSpacing: NSNumber! = 2
    
    static let headerViewIdentifier = "MMTWamLayoutHeaderViewIdentifier"
    
    // MARK: UICollectionViewLayout setup methods
    
    override func prepare()
    {
        guard collectionView!.numberOfSections > 0 else {
            return
        }

        itemSize = calculateItemSize()
        cellLayoutAttributes = MMTLayoutIndex()
        headerLayoutAttributes = MMTLayoutIndex()        

        for section in 0..<collectionView!.numberOfSections {
            for item in 0..<collectionView!.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                cellLayoutAttributes[indexPath] = createCellLayoutAttributesForIndexPath(indexPath)
            }
            
            let indexPath = IndexPath(item: 0, section: section)
            headerLayoutAttributes[indexPath] = createHeaderLayoutAttributesForIndexPath(indexPath)
        }        
    }
    
    fileprivate func calculateItemSize() -> CGSize
    {
        if let size = delegate?.collectionView?(collectionView!, itemSizeForLayout: self) {
            return size
        }
        return itemSize
    }
    
    fileprivate func createCellLayoutAttributesForIndexPath(_ indexPath: IndexPath) -> UICollectionViewLayoutAttributes
    {
        let
        itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        itemAttributes.frame = calculateFrameForCellAtIndexPath(indexPath)
        
        return itemAttributes
    }
    
    fileprivate func calculateFrameForCellAtIndexPath(_ indexPath: IndexPath) -> CGRect
    {
        let itemWidth = itemSize.width+CGFloat(itemSpacing)
        let itemHeight = itemSize.height+CGFloat(sectionSpacing)
        
        let x = CGFloat(indexPath.item)*itemWidth+CGFloat(headerViewWidth)+CGFloat(itemSpacing)
        let y = CGFloat(indexPath.section)*itemHeight
        
        return CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
    }
    
    fileprivate func createHeaderLayoutAttributesForIndexPath(_ indexPath: IndexPath) -> UICollectionViewLayoutAttributes
    {
        let identifier = MMTCollectionViewWamLayout.headerViewIdentifier
        
        let
        headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: identifier, with: indexPath)
        headerAttributes.frame = calculateFrameForHeaderAtIndexPath(indexPath)
        
        return headerAttributes
    }
    
    fileprivate func calculateFrameForHeaderAtIndexPath(_ indexPath: IndexPath) -> CGRect
    {
        let headerHeight = CGFloat(sectionSpacing)+itemSize.height
        let y = CGFloat(indexPath.section)*headerHeight
        
        return CGRect(x: 0, y: y, width: CGFloat(headerViewWidth), height: itemSize.height)
    }
    
    // MARK: UICollectionViewLayout methods
    
    override var collectionViewContentSize : CGSize
    {
        let itemWidth = Int(itemSize.width)+Int(itemSpacing)
        let itemHeight = Int(itemSize.height)+Int(sectionSpacing)
        let height = collectionView!.numberOfSections*itemHeight-Int(sectionSpacing)
        var width = 0
        
        for section in 0..<collectionView!.numberOfSections
        {
            let sectionWidth = collectionView!.numberOfItems(inSection: section)*itemWidth
            
            if sectionWidth > width {
                width = sectionWidth
            }
        }

        return CGSize(width: CGFloat(width)+CGFloat(headerViewWidth)+CGFloat(itemSpacing), height: CGFloat(height))
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        let cellAttributes = getElementsInRect(rect, fromIndex: cellLayoutAttributes)
        let headerAttributes = getElementsInRect(rect, fromIndex: headerLayoutAttributes)

        return cellAttributes+headerAttributes
    }
    
    fileprivate func getElementsInRect(_ rect: CGRect, fromIndex index: MMTLayoutIndex) -> [UICollectionViewLayoutAttributes]
    {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        for itemAttributes in index.values
        {
            if rect.intersects(itemAttributes.frame) {
                attributes.append(itemAttributes)
            }
        }
        
        return attributes;
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return cellLayoutAttributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return headerLayoutAttributes[indexPath]
    }    
}
