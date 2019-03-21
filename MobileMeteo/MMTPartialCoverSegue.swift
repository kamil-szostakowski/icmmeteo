//
//  MMTPartialCoverSegue.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import UIKit

class MMTPartialCoverSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate
{
    // MARK: Overrides
    override func perform()
    {
        destination.modalPresentationStyle = .custom
        destination.transitioningDelegate = self
        super.perform()
    }
    
    // MARK: UIViewControllerTransitioningDelegate methods
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        return MMTPartialCoverPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
