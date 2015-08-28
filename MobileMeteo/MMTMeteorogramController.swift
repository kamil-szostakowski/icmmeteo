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
    
    private var requestCount: Int = 0
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
        
        meteorogramStore.getMeteorogramForLocation(city.location, completion: completionWithErrorHandling(){
            (data: NSData?, error: NSError?) in
            
            self.meteorogramImage.image = UIImage(data: data!)
        })
        
        meteorogramStore.getMeteorogramLegend(completionWithErrorHandling(){
            (data: NSData?, error: NSError?) in
            
            self.legendImage.image = UIImage(data: data!)
        })
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
    
    private func completionWithErrorHandling(completion: MMTFetchMeteorogramCompletion) -> MMTFetchMeteorogramCompletion
    {
        return { (data: NSData?, error: NSError?) in
         
            self.requestCount += 1
            
            if let image = data
            {
                completion(data: data, error: error)
            }

            else if error?.domain == MMTErrorDomain
            {
                let message = MMTError(rawValue: error!.code)!.description
                UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: "zamknij").show()
            }
            
            if self.requestCount == 2
            {
                self.activityIndicator.hidden = true
            }
        }
    }    
}