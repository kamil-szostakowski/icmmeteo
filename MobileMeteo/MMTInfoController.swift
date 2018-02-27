//
//  MMTInfoController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MessageUI
import Foundation

class MMTMFMailComposeViewController: MFMailComposeViewController
{
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return .portrait
    }
}

class MMTInfoController: UIViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet var icons: [UIImageView]!
    
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        icons.forEach {
            $0.imageRenderingMode = UIImageRenderingMode.alwaysTemplate
        }
    }
    // MARK: Action methods
    @IBAction func feedbackBtnDidTap(_ sender: UIButton)
    {
        guard MFMailComposeViewController.canSendMail() else {
            
            present(UIAlertController.alertForMMTError(.mailNotAvailable), animated: true, completion: nil)
            return
        }
        
        let
        mailer = MMTMFMailComposeViewController()
        mailer.view.tintColor = MMTAppearance.textColor        
        mailer.setToRecipients(["meteo.contact1@gmail.com"])
        mailer.setSubject("ICM Meteo, Feedback")
        mailer.mailComposeDelegate = self
        
        present(mailer, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate methods    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        dismiss(animated: true, completion: nil)
    }
}
