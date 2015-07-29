//
//  MMTActionSheetPresentationController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 22.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTActionSheetPresentationController: UIPresentationController
{
    private typealias MMTMetrics = [NSObject: AnyObject]
    private typealias MMTTransistioning = (UIViewControllerTransitionCoordinatorContext!) -> Void
    
    // MARK: Properties
    
    private var dimmingView: UIVisualEffectView!
    private var dismissButton: UIButton!
    private let margin: CGFloat = 20
    
    // MARK: Initializers
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!)
    {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        setupDimmingView()
        setupDismissButton()
    }
    
    // MARK: Setup methods
    
    private func setupDimmingView()
    {
        dimmingView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        dimmingView.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    private func setupDismissButton()
    {
        dismissButton = UIButton()
        dismissButton.backgroundColor = UIColor(white: 0.94, alpha: 1)
        dismissButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        dismissButton.setTitle("Anuluj", forState: UIControlState.Normal)
        dismissButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        dismissButton.addTarget(self, action: Selector("dismissButtonDidClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
        dismissButton.layer.cornerRadius = 5
        dismissButton.layer.borderWidth = 1
        dismissButton.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    private func setupHierarchy()
    {
        presentedView().setTranslatesAutoresizingMaskIntoConstraints(false)
        presentedView().layer.cornerRadius = 5
        presentedView().layer.borderWidth = 1
        presentedView().layer.borderColor = UIColor.lightGrayColor().CGColor
        
        containerView.addSubview(dimmingView)
        containerView.addSubview(dismissButton)
        containerView.addSubview(presentedView())
    }
    
    // MARK: Overrides
    
    override func presentationTransitionWillBegin()
    {
        setupHierarchy()
        addConstraintsWithMetrics(offscreenMetrics)
        
        containerView.layoutIfNeeded()
        containerView.removeConstraints(containerView.constraints())
        
        addConstraintsWithMetrics(onscreenMetrics)
        
        presentingViewController.transitionCoordinator()?.animateAlongsideTransition(emptyCompletion, completion: emptyCompletion)
    }
    
    override func dismissalTransitionWillBegin()
    {
        containerView.removeConstraints(containerView.constraints())
        
        addConstraintsWithMetrics(offscreenMetrics)
        dimmingView.removeFromSuperview()
        
        presentingViewController.transitionCoordinator()?.animateAlongsideTransition(emptyCompletion, completion: emptyCompletion)
    }
    
    override func dismissalTransitionDidEnd(completed: Bool)
    {
        containerView.removeConstraints(containerView.constraints())
        
        dismissButton.removeFromSuperview()
        presentedView().removeFromSuperview()
    }
    
    // MARK: Actions
    
    func dismissButtonDidClicked(button: UIButton)
    {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helper methods
    
    private func addConstraintsWithMetrics(metrics: MMTMetrics)
    {
        let formats = ["V:|[dimmingView]|", "H:|[dimmingView]|", "H:|-margin-[presentedView]-margin-|", "V:[presentedView(==contentHeight)]-[dismissButton]-bottomMargin-|", "H:|-margin-[dismissButton]-margin-|"]
        
        for format in formats {
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: nil, metrics: metrics, views: bindings))
        }
    }
    
    private var emptyCompletion: MMTTransistioning
    {
        return {(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
        
            if self.containerView != nil {
                self.containerView.layoutIfNeeded()
            }
        }
    }
    
    private var onscreenMetrics: MMTMetrics
    {
        return ["margin": margin, "contentHeight": presentedViewController.view.frame.height, "bottomMargin": margin]
    }
    
    private var offscreenMetrics: MMTMetrics
    {
        let contentHeight = presentedViewController.view.frame.height
        return ["margin": margin, "contentHeight": contentHeight, "bottomMargin": -(contentHeight+3*margin)]
    }
    
    private var bindings: MMTMetrics
    {
        return ["dimmingView": dimmingView, "dismissButton": dismissButton, "presentedView": presentedView()]
    }
}