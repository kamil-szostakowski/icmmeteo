//
//  MMTPartialCoverPresentationController.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTPartialCoverPresentationController: UIPresentationController
{
    // MARK: Properties
    private lazy var dimmingView: UIView = {
        let
        view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var contentView: UIView = {
        let
        view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white        
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8;
        view.layer.shadowRadius = 5.0;
        view.layer.cornerRadius = 20
        return view
    }()
    
    // MARK: Overrides
    override var presentationStyle: UIModalPresentationStyle {
        return .overFullScreen
    }
    
    override var presentedView: UIView? {
        return contentView
    }
    
    override func presentationTransitionWillBegin()
    {
        guard let container = containerView else {
            return
        }
        
        presentedViewController.view.translatesAutoresizingMaskIntoConstraints = false
        presentedViewController.view.layer.cornerRadius = 20
        
        container.addFillingSubview(dimmingView)
        container.addFillingSubview(contentView, UIEdgeInsets(top: 40, left: 30, bottom: -40, right: -30))
        contentView.addFillingSubview(presentedViewController.view)
        
        animate(alpha: 0.6)
    }
    
    override func dismissalTransitionWillBegin()
    {
        animate(alpha: 0)
    }
}

extension MMTPartialCoverPresentationController
{
    // MARK: Helper methods
    fileprivate func animate(alpha: CGFloat)
    {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = alpha
        }, completion: nil)
    }
}
