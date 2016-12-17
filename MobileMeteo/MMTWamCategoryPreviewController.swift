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
    
    fileprivate var cache = NSCache<NSString, UIImage>()
    fileprivate var currentMoment: Int = 0

    var wamStore: MMTWamModelStore!
    
    fileprivate var isFirstMoment: Bool {
        return currentMoment == 0
    }
    
    fileprivate var isLastMoment: Bool {        
        return currentMoment == wamSettings.forecastMoments.count-1
    }
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()        
        
        navigationBar.topItem?.title = MMTTranslationWamCategory[wamSettings.selectedCategory!]
        meteorogramImage.accessibilityIdentifier = "\(wamSettings.selectedCategory!)"
        
        setupNavigationButtons()
        setupCurrentMomentIndex()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        setupScrollView()
        displayCurrentMoment()
        analytics?.sendScreenEntryReport("Model WAM category preview")
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: Setup methods
    
    fileprivate func setupNavigationButtons()
    {
        prevMomentButton.isEnabled = false
        prevMomentButton.accessibilityIdentifier = "PrevButton"
        
        nextMomentBtn.isEnabled = false
        nextMomentBtn.accessibilityIdentifier = "NextButton"
    }
    
    fileprivate func setupCurrentMomentIndex()
    {
        let moments = wamSettings.forecastMoments.map(){ $0.date }
        let selectedMoment = wamSettings.forecastSelectedMoments.first!.date
        
        currentMoment = moments.index(of: selectedMoment)!
    }
    
    fileprivate func setupMomentLabelForDate(_ date: Date)
    {
        let tZeroPlus = wamStore.getHoursFromForecastStartDate(forDate: date)
        let tZeroPlusString = String(format: MMTFormat.TZeroPlus, tZeroPlus)
        let momentString = DateFormatter.utcFormatter.string(from: date)
        
        momentLabel.text = "start \(tZeroPlusString) = \(momentString)"
    }
    
    fileprivate func setupScrollView()
    {
        meteorogramImage.updateSizeConstraints(wamStore.meteorogramSize)
        
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.zoomScaleFittingWidth(for: wamStore.meteorogramSize)
        scrollView.zoomScale = scrollView.zoomScaleFittingHeight(for: wamStore.meteorogramSize)
    }
    
    // MARK: Action methods    
    
    @IBAction func didClickNextMomentBtn(_ sender: UIBarButtonItem)
    {
        currentMoment += 1
        displayCurrentMoment()
    }

    @IBAction func didClickPreviousMomentBtn(_ sender: UIBarButtonItem)
    {
        currentMoment -= 1
        displayCurrentMoment()
    }
    
    @IBAction func didRecognizedDoubleTapGesture(_ sender: UITapGestureRecognizer)
    {
        let defaultZoomScale = scrollView.zoomScaleFittingHeight(for: wamStore.meteorogramSize)
        
        scrollView.animateZoom(scale: defaultZoomScale)
    }

    // MARK: UIScrollViewDelegate methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return meteorogramImage
    }
    
    // MARK: Helper methods
    
    fileprivate func displayCurrentMoment()
    {
        let moment = wamSettings.forecastMoments[currentMoment].date
        let category = wamSettings.selectedCategory!
        
        setupMomentLabelForDate(moment as Date)
        
        prevMomentButton.isEnabled = false
        nextMomentBtn.isEnabled = false
        
        getMeteorogramWithQuery(MMTWamModelMeteorogramQuery(category: category, moment: moment)){
            (image: UIImage?, error: MMTError?) in
            
            self.meteorogramImage.image = image
            self.prevMomentButton.isEnabled = !self.isFirstMoment
            self.nextMomentBtn.isEnabled = !self.isLastMoment
        }
    }
    
    fileprivate func getMeteorogramWithQuery(_ query: MMTWamModelMeteorogramQuery, completion: @escaping MMTFetchMeteorogramCompletion)
    {
        let key = "\(query.moment)" as NSString
        
        if let image = cache.object(forKey: key)
        {
            completion(image, nil)
            return
        }
        
        activityIndicator.isHidden = false
        
        wamStore.getMeteorogramMomentWithQuery(query){
            (img: UIImage?, error: MMTError?) in
            
            self.activityIndicator.isHidden = true
            
            guard let image = img, error == nil else
            {
                let alert = UIAlertController.alertForMMTError(error!){ (UIAlertAction) -> Void in
                    self.performSegue(withIdentifier: MMTSegue.UnwindToWamModel, sender: self)
                }
                
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.cache.setObject(image, forKey: key)
            completion(image, error)
        }
    }
}
