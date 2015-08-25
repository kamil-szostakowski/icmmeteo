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
    
    var query: MMTGridModelMeteorogramQuery!
    var meteorogramStore: MMTGridClimateModelStore!
    
    private var requestCount: Int = 0
    
    private var minZoomScale: CGFloat {
        return scrollView.bounds.width/meteorogramStore.meteorogramSize.width
    }
    
    private var defaultZoomScale: CGFloat {
        return scrollView.bounds.height/meteorogramStore.meteorogramSize.height
    }

    // MARK: Controller methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationBar.topItem!.title = query.locationName
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        setupScrollView()
        
        meteorogramStore.getMeteorogramForLocation(query.location, completion: completionWithErrorHandling(){
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
        setupImage(meteorogramImage, withSize: meteorogramStore.meteorogramSize)
        setupImage(legendImage, withSize: meteorogramStore.legendSize)

        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = minZoomScale
        scrollView.zoomScale = defaultZoomScale
    }
    
    private func setupImage(image: UIImageView, withSize size: CGSize)
    {
        for constraint in image.constraints() as! [NSLayoutConstraint]
        {
            if constraint.firstAttribute == NSLayoutAttribute.Width {
                constraint.constant = size.width
            }
            
            if constraint.firstAttribute == NSLayoutAttribute.Height {
                constraint.constant = size.height
            }
        }
    }

    // MARK: Actions

    @IBAction func onCloseBtnTouchAction(sender: UIBarButtonItem)
    {        
        performSegueWithIdentifier(MMTSegue.UnwindToListOfCities, sender: self)
    }
    
    @IBAction func onScrollViewDoubleTapAction(sender: UITapGestureRecognizer)
    {
        let animation = { () -> Void in
        
            self.scrollView.zoomScale = self.defaultZoomScale
            self.scrollView.contentOffset = CGPoint.zeroPoint
        }
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: nil, animations: animation, completion: nil)
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
            
            if let err = error {
                NSLog("Image fetch error \(error)")
            }
            
            else {
                completion(data: data, error: error)
            }
            
            if self.requestCount == 2 {
                self.activityIndicator.hidden = true
            }
        }
    }
}