//
//  MMTInfoController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MeteoModel

class MMTInfoController: UIViewController
{
    // MARK: Properties
    @IBOutlet var icons: [UIImageView]!
    @IBOutlet weak var iconsCredit: UITextView!
    @IBOutlet weak var qaCredit: UITextView!
    @IBOutlet weak var authorCredit: UITextView!
    @IBOutlet weak var onboardingButton: UIButton!    
    @IBOutlet weak var feedbackButton: UIButton!
    
    fileprivate var modelController: MMTInfoModelController!
    
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCreditsUrls()
        setupIconsTint()
        setupModelController()
        
        onboardingButton.layer.borderColor = MMTAppearance.meteoGreenColor.cgColor
        feedbackButton.layer.borderColor = MMTAppearance.meteoGreenColor.cgColor
    }
}

extension MMTInfoController
{
    // MARK: Actions methods
    @IBAction func feedbackBtnDidTap(_ sender: UIButton)
    {
        let subject = modelController.feedbackEmailTopic
        let recipient = modelController.feedbackEmailRecipient
        
        guard let mailer = MMTMailComposer(subject, recipient) else {
            present(UIAlertController.alertForMMTError(.mailNotAvailable), animated: true, completion: nil)
            return
        }
        
        present(mailer, animated: true, completion: nil)
    }
}

extension MMTInfoController: UITextViewDelegate, MMTModelControllerDelegate
{
    // MARK: Delegate methods
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool
    {
        return true
    }
    
    func onModelUpdate(_ controller: MMTModelController)
    {
        iconsCredit.attributedText = modelController.weatherIconsCredit
        qaCredit.attributedText = modelController.qaSupportCredit
        authorCredit.attributedText = modelController.authorCredit
    }
}

extension MMTInfoController
{
    // MARK: Setup methods
    fileprivate func setupModelController()
    {
        modelController = MMTInfoModelController(font: iconsCredit.font!)
        modelController.delegate = self
        modelController.activate()
    }
    
    fileprivate func setupCreditsUrls()
    {
        [iconsCredit, qaCredit, authorCredit].forEach {
            $0?.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        }
    }
    
    fileprivate func setupIconsTint()
    {
        icons.forEach { $0.imageRenderingMode = .alwaysTemplate }
    }
}
