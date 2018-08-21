//
//  MMTInfoController.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 01.02.2016.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import UIKit

class MMTInfoController: UIViewController, UITextViewDelegate
{
    // MARK: Properties
    @IBOutlet var icons: [UIImageView]!
    @IBOutlet weak var iconsCredit: UITextView!
    @IBOutlet weak var qaCredit: UITextView!
    @IBOutlet weak var authorCredit: UITextView!
    
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCreditsUrls()
        setupIconsTint()
    }
    
    // MARK: Action methods
    @IBAction func feedbackBtnDidTap(_ sender: UIButton)
    {
        guard let mailer = MMTMailComposer(subject: "ICM Meteo, Feedback", recipient: "meteo.contact1@gmail.com") else {
            present(UIAlertController.alertForMMTError(.mailNotAvailable), animated: true, completion: nil)
            return
        }
        
        present(mailer, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool
    {
        return true
    }
}

extension MMTInfoController
{
    // MARK: Setup methods
    fileprivate func setupCreditsUrls()
    {
        let insets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        
        let
        iconsCreditString = NSMutableAttributedString(textView: iconsCredit)
        iconsCreditString.set(url: CreditsURL.iconsSet, for: "The Weather is Nice Today")
        iconsCreditString.set(url: CreditsURL.iconsAuthor, for: "Laura Reen")
        iconsCreditString.set(url: CreditsURL.iconsLicense, for: "CC BY-NC 3.0")
        
        iconsCredit.textContainerInset = insets
        iconsCredit.attributedText = iconsCreditString
        
        let
        qaCreditString = NSMutableAttributedString(textView: qaCredit)
        qaCreditString.set(url: CreditsURL.qaSupport, for: qaCredit.text)
        
        qaCredit.textContainerInset = insets
        qaCredit.attributedText = qaCreditString
        
        let
        authorCreditString = NSMutableAttributedString(textView: authorCredit)
        authorCreditString.set(url: CreditsURL.authorLinkedIt, for: "Kamil Szostakowski")
        authorCreditString.set(url: CreditsURL.authorGithub, for: "GitHub")
        authorCreditString.set(url: CreditsURL.authorStackOverflow, for: "Stack Overflow")
        
        authorCredit.textContainerInset = insets
        authorCredit.attributedText = authorCreditString
    }
    
    fileprivate func setupIconsTint()
    {
        icons.forEach { $0.imageRenderingMode = .alwaysTemplate }
    }
}

struct CreditsURL
{
    static let iconsSet = "https://www.iconfinder.com/iconsets/the-weather-is-nice-today"
    static let iconsAuthor = "https://www.iconfinder.com/laurareen"
    static let iconsLicense = "https://creativecommons.org/licenses/by-nc/3.0/deed.en"
    static let qaSupport = "https://www.linkedin.com/in/bartosz-%C5%9Bwie%C5%BCawski-046781b3/"
    static let authorLinkedIt = "https://www.linkedin.com/in/kamil-szostakowski-407080a2/"
    static let authorGithub = "https://github.com/kamil-szostakowski"
    static let authorStackOverflow = "https://stackoverflow.com/users/1692080/kamil-szostakowski"
}
