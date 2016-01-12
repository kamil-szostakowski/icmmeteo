//
//  MMTWamCategoryPreviewController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 26.08.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTWamCategoryPreviewController: UIViewController, UIScrollViewDelegate
{
    @IBOutlet var prevMomentButton: UIBarButtonItem!
    @IBOutlet var nextMomentBtn: UIBarButtonItem!
    @IBOutlet var meteorogramImage: UIImageView!
    @IBOutlet var activityIndicator: UIView!
    @IBOutlet var momentLabel: UILabel!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var scrollView: UIScrollView!
    
    @NSCopying var wamSettings: MMTWamSettings!
    
    private var cache: NSCache = NSCache()
    private var wamStore = MMTWamModelStore(date: NSDate())
    private var currentMoment: Int = 0

    
    private var isFirstMoment: Bool {
        return currentMoment == 0
    }
    
    private var isLastMoment: Bool {
        return currentMoment == wamSettings.forecastMoments.count-1
    }
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationBar.topItem?.title = wamSettings.selectedCategory?.description                
        meteorogramImage.accessibilityIdentifier = "\(wamSettings.selectedCategory!)"
        
        setupNavigationButtons()
        setupCurrentMomentIndex()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        setupScrollView()
        displayCurrentMoment()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // MARK: Setup methods
    
    private func setupNavigationButtons()
    {
        prevMomentButton.enabled = false
        prevMomentButton.accessibilityIdentifier = "PrevButton"
        
        nextMomentBtn.enabled = false
        nextMomentBtn.accessibilityIdentifier = "NextButton"
    }
    
    private func setupCurrentMomentIndex()
    {
        let moments = wamSettings.forecastMoments.map(){ $0.date }
        let selectedMoment = wamSettings.forecastSelectedMoments.first!.date
        
        currentMoment = moments.indexOf(selectedMoment)!
    }
    
    private func setupMomentLabelForDate(date: NSDate)
    {
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        
        let tZeroPlusString = String(NSString(format: MMTFormat.TZeroPlus, tZeroPlus))
        let momentString = NSDateFormatter.shortStyleUtcDatetime(date)
        
        momentLabel.text = "start \(tZeroPlusString) = \(momentString)"
    }
    
    private func setupScrollView()
    {
        meteorogramImage.updateSizeConstraints(wamStore.meteorogramSize)
        
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.minZoomScaleForSize(wamStore.meteorogramSize)
        scrollView.zoomScale = scrollView.defaultZoomScale(wamStore.meteorogramSize)        
    }
    
    // MARK: Action methods    
    
    @IBAction func didClickNextMomentBtn(sender: UIBarButtonItem)
    {
        currentMoment++
        displayCurrentMoment()
    }

    @IBAction func didClickPreviousMomentBtn(sender: UIBarButtonItem)
    {
        currentMoment--
        displayCurrentMoment()
    }
    
    @IBAction func didRecognizedDoubleTapGesture(sender: UITapGestureRecognizer)
    {
        let defaultZoomScale = scrollView.defaultZoomScale(wamStore.meteorogramSize)
        
        scrollView.animatedZoomToScale(defaultZoomScale)
    }

    // MARK: UIScrollViewDelegate methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return meteorogramImage
    }
    
    // MARK: Helper methods
    
    private func displayCurrentMoment()
    {
        let moment = wamSettings.forecastMoments[currentMoment].date
        let category = wamSettings.selectedCategory!
        
        setupMomentLabelForDate(moment)
        
        prevMomentButton.enabled = false
        nextMomentBtn.enabled = false
        
        getMeteorogramWithQuery(MMTWamModelMeteorogramQuery(category: category, moment: moment)){
            
            (data: NSData?, error: NSError?) in
            
            self.meteorogramImage.image = UIImage(data: data!)            
            self.prevMomentButton.enabled = !self.isFirstMoment
            self.nextMomentBtn.enabled = !self.isLastMoment
        }
    }
    
    private func getMeteorogramWithQuery(query: MMTWamModelMeteorogramQuery, completion: MMTFetchMeteorogramCompletion)
    {
        let key = "\(query.moment)"
        
        if let data = cache.objectForKey(key) as? NSData
        {
            completion(data: data, error: nil)
            return
        }
        
        activityIndicator.hidden = false
        
        wamStore.getMeteorogramMomentWithQuery(query){
            (data: NSData?, error: NSError?) in
            
            self.activityIndicator.hidden = true
            
            if let image = data
            {
                self.cache.setObject(image, forKey: key)
                completion(data: data, error: error)
            }
                
            else if error?.domain == MMTErrorDomain
            {
                let message = MMTError(rawValue: error!.code)!.description
                UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: "zamknij").show()
            }
        }
    }
}