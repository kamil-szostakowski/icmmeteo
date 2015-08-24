//
//  MMTMeteorogramWamController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

typealias MMTWamMeteorogramsCache = [NSDate: NSData]

class MMTMeteorogramWamController: UIViewController, UICollectionViewDataSource, MMTCollectionViewDelegateWamLayout
{
    // MARK: Outlets
    
    @IBOutlet var forecastLength: UILabel!
    @IBOutlet var forecastStart: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    private var cache: NSCache = NSCache()
    private var wamSettings: MMTWamSettings!
    private var wamStore: MMTWamModelStore!
    private var presented = false

    // MARK: Properties

    private var itemHeight: CGFloat
    {
        let categoriesCount = wamSettings.selectedCategories.count
        let spacesCount = max(categoriesCount-1, 0)
        let spacing = CGFloat(spacesCount*layout.sectionSpacing.integerValue)
        
        return (collectionView.frame.size.height-spacing)/CGFloat(categoriesCount)
    }
    
    private var layout: MMTCollectionViewWamLayout {
        return collectionView.collectionViewLayout as! MMTCollectionViewWamLayout
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        wamStore = MMTWamModelStore(date: NSDate())        
        
        setupInfoBar()
        setupSettings()
        setupCollectionView()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        presented = true
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.presented = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == MMTSegue.DisplayWamSettings {
            segue.destinationViewController.setValue(wamSettings, forKey: "wamSettings")
        }
    }
    
    // MARK: Setup methods
    
    private func setupSettings()
    {
        wamSettings = MMTWamSettings(wamStore.getForecastMoments())
        
        for moment in wamSettings.forecastMomentsGrouppedByDay.first! {
            wamSettings.setMomentSelection(moment.date, selected: true)
        }
    }
    
    private func setupCollectionView()
    {
        let headerClass: AnyClass = MMTWamHeaderView.classForCoder()
        let identifier = MMTCollectionViewWamLayout.headerViewIdentifier
        
        collectionView.registerClass(headerClass, forSupplementaryViewOfKind: identifier, withReuseIdentifier: identifier)
    }
    
    private func setupInfoBar()
    {
        forecastLength.text = "Długość prognozy: \(wamStore.forecastLength)h"
        forecastStart.text = "start prognozy t0: \(NSDateFormatter.shortStyleUtcDatetime(wamStore.forecastStartDate))"
    }
    
    // MARK: Actions
    
    @IBAction func unwindToWamModel(unwindSegue: UIStoryboardSegue)
    {
        wamSettings = unwindSegue.sourceViewController.valueForKey("wamSettings") as! MMTWamSettings
    }
    
    // MARK: UICollectionViewDataSource methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return presented ? wamSettings.selectedCategories.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return wamSettings.forecastSelectedMoments.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let date = wamSettings.forecastSelectedMoments[indexPath.row].date
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        let category = wamSettings.selectedCategories[indexPath.section]
        
        let
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("WamMomentItem", forIndexPath: indexPath) as! MMTWamCategoryItem
        cell.headerLabel.text = NSDateFormatter.shortStyleUtcDatetime(date)
        cell.footerLabel.text = String(NSString(format: MMTFormat.TZeroPlus, tZeroPlus))
        
        getThumbnailWithQuery(MMTWamModelMeteorogramQuery(category, date)) {
            (data: NSData?, error: NSError?) in
        
            if let err = error {
                NSLog("Thumbnail fetch error")
                return
            }
            
            if let image = data {
                cell.map.image = UIImage(data: image)
            }
        }
        
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
        let
        headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kind, forIndexPath: indexPath) as! MMTWamHeaderView
        headerView.categoryTitle = wamSettings.selectedCategories[indexPath.section].description

        return headerView
    }
    
    // MARK: Helper methods    
    
    private func getThumbnailWithQuery(query: MMTWamModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        let key = "\(query.category.rawValue)\(query.moment)"
        
        if let data = cache.objectForKey(key) as? NSData
        {
            completion(data: data, error: nil)
            return
        }

        wamStore.getMeteorogramMomentThumbnailWithQuery(query) {
            (data: NSData?, error: NSError?) in
            
            if let image = data {
                self.cache.setObject(image, forKey: key)
            }
            
            completion(data: data, error: error)
        }
    }
}