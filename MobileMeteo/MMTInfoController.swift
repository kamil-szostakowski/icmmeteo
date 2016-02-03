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

class MMTInfoController: UIViewController, MFMailComposeViewControllerDelegate
{        
    // MARK: Action methods
    
    @IBAction func feedbackBtnDidTap(sender: UIButton)
    {
        guard MFMailComposeViewController.canSendMail() else {
            
            presentViewController(UIAlertController.alertForMMTError(.MailNotAvailable), animated: true, completion: nil)
            return
        }
        
        let
        mailer = MFMailComposeViewController()
        mailer.view.tintColor = MMTAppearance.textColor        
        mailer.setToRecipients(["meteo.contact1@gmail.com"])
        mailer.setSubject("ICM Meteo, Feedback")
        mailer.mailComposeDelegate = self
        
        presentViewController(mailer, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate methods
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}