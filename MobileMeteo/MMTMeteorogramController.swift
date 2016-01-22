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

class MMTMeteorogramController: UIViewController, UIScrollViewDelegate
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
    
    private var meteorogramType: String {
        return meteorogramStore is MMTUmModelStore ? "UM" : "COAMPS"
    }

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
        
        analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplay, actionLabel: meteorogramType)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animateAlongsideTransition(nil) { (UIViewControllerTransitionCoordinatorContext) -> Void in                
            self.adjustZoomScale()
        }
        
        if newCollection.verticalSizeClass == .Compact {
            analytics?.sendUserActionReport(.Meteorogram, action: .MeteorogramDidDisplayInLandscape, actionLabel: meteorogramType)
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
            (data: NSData?, error: MMTError?) in
            
            guard error == nil else
            {
                self.displayErrorAlert(error!)
                return
            }
            
            self.meteorogramImage.image = UIImage(data: data!)
            self.activityIndicator.hidden = true
        }
    }
    
    private func setupMeteorogramLegend()
    {
        meteorogramStore.getMeteorogramLegend(){
            (data: NSData?, error: MMTError?) in
            
            guard error == nil else
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
        citiesStore.markCity(city, asFavourite: city.isFavourite)
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
        
        let action: MMTAnalyticsAction = city.isFavourite ?
            MMTAnalyticsAction.LocationDidAddToFavourites :
            MMTAnalyticsAction.LocationDidRemoveFromFavourites        
        
        analytics?.sendUserActionReport(.Locations, action: action, actionLabel:  city.name)
    }

    // MARK: UIScrollViewDelegate methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return scrollViewContainer
    }
    
    // MARK: Helper methods
    
    private func adjustZoomScale()
    {
        scrollView.animatedZoomToScale(zoomScaleForVisibleContentSize(visibleContentSize()))
    }
    
    private func visibleContentSize() -> CGSize
    {
        var contentSize = meteorogramStore.meteorogramSize
        
        if traitCollection.verticalSizeClass == .Compact {
            contentSize.width += meteorogramStore.legendSize.width
        }
        
        return contentSize
    }
    
    private func zoomScaleForVisibleContentSize(size: CGSize) -> CGFloat
    {
        let isLandscape = traitCollection.verticalSizeClass == .Compact
        
        return isLandscape ? scrollView.minZoomScaleForSize(size) : scrollView.defaultZoomScale(size)
    }
    
    private func displayErrorAlert(error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ (UIAlertAction) -> Void in
            self.performSegueWithIdentifier(MMTSegue.UnwindToListOfCities, sender: self)
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
}