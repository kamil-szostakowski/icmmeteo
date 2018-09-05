//
//  MMTMailComposer.swift
//  MobileMeteo
//
//  Created by szostakowskik on 21.08.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import MessageUI

class MMTMailComposer: MFMailComposeViewController, MFMailComposeViewControllerDelegate
{
    // Initializers
    convenience init?(_ subject: String, _ recipient: String)
    {
        guard MFMailComposeViewController.canSendMail() else {
            return nil
        }
        
        self.init()
        setToRecipients([recipient])
        setSubject(subject)
        view.tintColor = MMTAppearance.textColor
        mailComposeDelegate = self
    }
    
    // MARK: Lifecycle methods
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    // MARK: MFMailComposeViewControllerDelegate methods
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        dismiss(animated: true, completion: nil)
    }
}
