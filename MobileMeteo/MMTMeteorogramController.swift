//
//  MMTMeteorogramController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 08.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class MMTMeteorogramController: UIViewController, UIScrollViewDelegate, UIAlertViewDelegate
{
    // MARK: Outlets
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var meteorogramImage: UIImageView!
    @IBOutlet var legendImage: UIImageView!
    @IBOutlet var activityIndicator: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewContainer: UIView!
    
    // MARK: Properties
    
    var city: MMTCity!
    var meteorogramStore: MMTGridClimateModelStore!
    
    private var citiesStore: MMTCitiesStore!

    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        citiesStore = MMTCitiesStore(db: MMTDatabase.instance)
        navigationBar.topItem!.title = city.name

        setupStarButton()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
                
        setupScrollView()        
        setupMeteorogram()
        setupMeteorogramLegend()
    }
    
    // MARK: Setup methods
    
    private func setupScrollView()
    {
        meteorogramImage.updateSizeConstraints(meteorogramStore.meteorogramSize)
        legendImage.updateSizeConstraints(meteorogramStore.legendSize)

        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.minZoomScaleForSize(meteorogramStore.meteorogramSize)
        scrollView.zoomScale = scrollView.defaultZoomScale(meteorogramStore.meteorogramSize)
    }
    
    private func setupStarButton()
    {
        let imageName = city.isFavourite ? "star" : "star-outline"
        navigationBar.topItem?.rightBarButtonItem?.image = UIImage(named: imageName)
    }
    
    private func setupMeteorogram()
    {
        meteorogramStore.getMeteorogramForLocation(city.location){
            (data: NSData?, error: NSError?) in
            
            if let e = error
            {
                UIAlertView(title: "", message: MMTError(rawValue: e.code)!.description, delegate: self, cancelButtonTitle: "zamknij").show()
                return
            }
            
            self.meteorogramImage.image = UIImage(data: data!)
            self.activityIndicator.hidden = true
        }
    }
    
    private func setupMeteorogramLegend()
    {
        meteorogramStore.getMeteorogramLegend(){
            (data: NSData?, error: NSError?) in
            
            if error != nil
            {
                var
                size = self.meteorogramStore.legendSize
                size.width = 0
                
                self.legendImage.updateSizeConstraints(size)
                return
            }
            
            self.legendImage.image = UIImage(data: data!)
        }
    }

    // MARK: Actions

    @IBAction func onCloseBtnTouchAction(sender: UIBarButtonItem)
    {        
        performSegueWithIdentifier(MMTSegue.UnwindToListOfCities, sender: self)
    }
    
    @IBAction func onScrollViewDoubleTapAction(sender: UITapGestureRecognizer)
    {
        let defaultZoomScale = scrollView.defaultZoomScale(meteorogramStore.meteorogramSize)
        
        scrollView.animatedZoomToScale(defaultZoomScale)
    }
    
    @IBAction func onStartBtnTouchAction(sender: UIBarButtonItem)
    {
        citiesStore.markCity(city, asFavourite: !city.isFavourite)
        setupStarButton()        
    }

    // MARK: UIScrollViewDelegate methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return scrollViewContainer
    }
    
    // MARK: UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        performSegueWithIdentifier(MMTSegue.UnwindToListOfCities, sender: self)
    }
    
    // MARK: Helper methods
    
}