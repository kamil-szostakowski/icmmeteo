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
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        citiesStore.markCity(city, asFavourite: city.isFavourite)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition(nil) { (UIViewControllerTransitionCoordinatorContext) -> Void in
                
            self.adjustZoomScale()
        }
    }
    
    // MARK: Setup methods
    
    private func setupScrollView()
    {
        let contentSize = visibleContentSize()
        let zoomScale = zoomScaleForVisibleContentSize(contentSize)
        
        meteorogramImage.updateSizeConstraints(meteorogramStore.meteorogramSize)
        legendImage.updateSizeConstraints(meteorogramStore.legendSize)

        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = scrollView.minZoomScaleForSize(contentSize)
        scrollView.zoomScale = zoomScale
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
        adjustZoomScale()
    }
    
    @IBAction func onStartBtnTouchAction(sender: UIBarButtonItem)
    {
        if let button = (navigationBar.layer.sublayers!.maxElement(){ $0.position.x < $1.position.x }) {
            button.addAnimation(CAAnimation.defaultScaleAnimation(), forKey: "scale")
        }                
        
        city.favourite = !city.isFavourite
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
    
    private func adjustZoomScale()
    {
        scrollView.animatedZoomToScale(zoomScaleForVisibleContentSize(visibleContentSize()))
    }
    
    private func visibleContentSize() -> CGSize
    {
        var contentSize = meteorogramStore.meteorogramSize
        
        if self.traitCollection.verticalSizeClass == .Compact {
            contentSize.width += meteorogramStore.legendSize.width
        }
        
        return contentSize
    }
    
    private func zoomScaleForVisibleContentSize(size: CGSize) -> CGFloat
    {
        let isLandscape = self.traitCollection.verticalSizeClass == .Compact
        
        return isLandscape ? scrollView.minZoomScaleForSize(size) : scrollView.defaultZoomScale(size)
    }
}