//
//  MMTMeteorogramWamController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTMeteorogramWamController: UIViewController, UICollectionViewDataSource, MMTCollectionViewDelegateWamLayout
{
    // MARK: Outlets
    
    @IBOutlet var refreshControl: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var refreshControlTrailingOffset: NSLayoutConstraint!

    // MARK: Properties
    
    private var categoriesCount = 0

    private var itemHeight: CGFloat
    {
        let spacesCount = max(categoriesCount-1, 0)
        let spacing = CGFloat(spacesCount*layout.sectionSpacing.integerValue)
        
        return (collectionView.frame.size.height-spacing)/CGFloat(categoriesCount)
    }
    
    private var layout: MMTCollectionViewWamLayout {
        return collectionView.collectionViewLayout as! MMTCollectionViewWamLayout
    }
    
    private var isRefreshing: Bool {
        return refreshControlTrailingOffset.constant == 0
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        let headerClass: AnyClass = MMTWamHeaderView.classForCoder()
        let identifier = MMTCollectionViewWamLayout.headerViewIdentifier
        
        categoriesCount = 3
        collectionView.registerClass(headerClass, forSupplementaryViewOfKind: identifier, withReuseIdentifier: identifier)
        collectionView.reloadData()
        
        refreshControlTrailingOffset.constant = -refreshControl.frame.size.width
    }
    
    @IBAction func unwindToWamModel(unwindSegue: UIStoryboardSegue)
    {
    }
    
    // MARK: UICollectionViewDataSource methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return categoriesCount
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("WamMomentItem", forIndexPath: indexPath) as! MMTWamCategoryItem
        
        cell.map.image = UIImage(named: "map\(indexPath.section+1)")
        cell.title.text = "t0 +00\(indexPath.item)"

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, itemSizeForLayout collectionViewLayout: UICollectionViewLayout) -> CGSize
    {
        let width = itemHeight*0.928
        return CGSizeMake(width, itemHeight)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath)
        -> UICollectionReusableView
    {
        let categories = ["Wysokość fali znacznej i średni kierunek fali", "Średni okres fali", "Okres piku widma"]
        
        let
        headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kind, forIndexPath: indexPath) as! MMTWamHeaderView
        headerView.categoryTitle = categories[indexPath.section]

        return headerView
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let isInitialOffset = scrollView.contentOffset == CGPointZero
        
        let contentSize = scrollView.contentSize.width
        let contentShift = scrollView.contentOffset.x+scrollView.frame.size.width
        
        if !isInitialOffset && !isRefreshing && contentShift-contentSize>50 {
            setRefreshing(true)
        }
    }    
    
    private func setRefreshing(refreshing: Bool)
    {
        let offset = refreshing ? 0 : -refreshControl.frame.size.width
        let animation = { () -> Void in
            
            self.refreshControlTrailingOffset.constant = offset
            self.view.layoutIfNeeded()
        }
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: nil, animations: animation, completion: nil)
    }
}