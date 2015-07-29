//
//  MMTActionSheetTransitioningDelegate.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 22.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTActionSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning
{
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return self;
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController?
    {
        return MMTActionSheetPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let duration = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay:0, usingSpringWithDamping:0.7, initialSpringVelocity:8, options:nil, animations:{}, completion:
            {(finished: Bool) in transitionContext.completeTransition(finished) })
    }
}