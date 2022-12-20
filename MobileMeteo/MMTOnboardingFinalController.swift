//
//  MMTOnboardingFinalController.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTOnboardingFinalController: UIViewController
{
    // MARK: Properties
    @IBOutlet weak var gettingStartedButton: UIButton!
    
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupButtons()
    }
}

// MARK: Setup methods
extension MMTOnboardingFinalController
{
    fileprivate func setupButtons()
    {
        gettingStartedButton.layer.borderWidth = 1
        gettingStartedButton.layer.cornerRadius = 5
        gettingStartedButton.layer.borderColor = MMTAppearance.meteoGreenColor.cgColor
    }
}

// MARK: Action methods
extension MMTOnboardingFinalController
{
    @IBAction func onTapCloseButton(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
}
