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
    
    private var categories: [MMTWamCategory] = [.TideHeight, .AvgTidePeriod, .SpectrumPeakPeriod]
    private var cache: NSCache = NSCache()
    private var wamSettings: MMTWamSettings!
    private var categoryPreviewSettings: MMTWamSettings!
    private var wamStore: MMTWamModelStore!
    private var presented = false
    private var failureCount = 0
    private var failureWatch: NSTimer!

    // MARK: Properties

    private var itemHeight: CGFloat
    {
        let spacesCount = max(categories.count-1, 0)
        let spacing = CGFloat(spacesCount*layout.sectionSpacing.integerValue)
        
        return (collectionView.frame.size.height-spacing)/CGFloat(categories.count)
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
        failureWatch = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "failureCheck", userInfo: nil, repeats: true)
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        presented = false
        failureWatch.invalidate()
        failureWatch = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == MMTSegue.DisplayWamSettings {
            segue.destinationViewController.setValue(wamSettings, forKey: "wamSettings")
        }
        
        if segue.identifier == MMTSegue.DisplayWamCategoryPreview {
            segue.destinationViewController.setValue(categoryPreviewSettings, forKey: "wamSettings")
        }
    }
    
    // MARK: Setup methods
    
    private func setupSettings()
    {
        wamSettings = MMTWamSettings(wamStore.getForecastMoments())
        categoryPreviewSettings = MMTWamSettings(wamStore.getForecastMoments())
        
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
        forecastStart.text = "Start prognozy t0: \(NSDateFormatter.shortStyleUtcDatetime(wamStore.forecastStartDate))"        
        forecastLength.text = "Długość prognozy: \(wamStore.forecastLength)h"
    }
    
    // MARK: Actions
    
    @IBAction func unwindToWamModel(unwindSegue: UIStoryboardSegue)
    {
    }
    
    @IBAction func unwindToWamModelAndUpdateSettings(unwindSegue: UIStoryboardSegue)
    {
        if let controller = unwindSegue.sourceViewController as? MMTModelWamSettingsController {
            wamSettings = controller.wamSettings
        }
    }
    
    @objc func failureCheck()
    {
        if failureCount>0
        {
            failureCount=0
            collectionView.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return presented ? categories.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return wamSettings.forecastSelectedMoments.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let date = wamSettings.forecastSelectedMoments[indexPath.row].date
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        let category = categories[indexPath.section]
        
        let
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("WamMomentItem", forIndexPath: indexPath) as! MMTWamCategoryItem
        cell.headerLabel.text = NSDateFormatter.shortStyleUtcDatetime(date)
        cell.footerLabel.text = String(NSString(format: MMTFormat.TZeroPlus, tZeroPlus))
        cell.accessibilityIdentifier = "\(category) +\(tZeroPlus)"        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        getThumbnailWithQuery(MMTWamModelMeteorogramQuery(category, date)) {
            (data: NSData?, error: NSError?) in
        
            if error != nil {
                self.failureCount++
            }            
            else if let image = data {
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
        headerView.categoryTitle = categories[indexPath.section].description

        return headerView
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let startMoment = categoryPreviewSettings.forecastMoments[indexPath.row].date
        let selectedMoments = categoryPreviewSettings.forecastSelectedMoments.map(){ $0.date }
        
        categoryPreviewSettings.selectedCategory = categories[indexPath.section]
        categoryPreviewSettings.setMomentsSelection(selectedMoments, selected: false)
        categoryPreviewSettings.setMomentSelection(startMoment, selected: true)
        
        performSegueWithIdentifier(MMTSegue.DisplayWamCategoryPreview, sender: self)
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