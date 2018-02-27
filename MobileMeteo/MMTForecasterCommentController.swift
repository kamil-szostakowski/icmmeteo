//
//  MMTForecasterCommentController.swift
//  MobileMeteo
//
//  Created by szostakowskik on 20.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import CoreText

// MARK: Lifecycle extension
class MMTForecasterCommentController: UIViewController, MMTActivityIndicating
{
    // MARK: Outlets
    @IBOutlet weak var textView: UITextView!
    
    var activityIndicator: MMTActivityIndicator!
    var lastUpdate: Date = Date.distantPast
    
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupTextView(content: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setupNotificationHandler()
        updateTextViewContentIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Setup extension
fileprivate extension MMTForecasterCommentController
{
    func updateTextViewContentIfNeeded()
    {
        guard Date().timeIntervalSince(lastUpdate) > TimeInterval(hours: 1) else {
            return
        }
        
        MMTForecasterCommentStore().getForecasterComment { (comment, error) in
            guard let content = comment else {
                self.displayErrorAlert(error!)
                return
            }
            
            self.setupTextView(content: self.formatted(content: content))
            self.lastUpdate = Date()
        }
    }
    
    func setupTextView(content: NSAttributedString?)
    {
        textView.attributedText = content
        textView.contentOffset = .zero
        textView.isUserInteractionEnabled = content != nil
        
        if content != nil {
            hideActivityIndicator()
        } else {
            displayActivityIndicator(in: view, message: MMTLocalizedString("label.loading.comment"))
        }
    }
    
    func setupNotificationHandler()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
}

// MARK: Utility extension
fileprivate extension MMTForecasterCommentController
{
    func displayErrorAlert(_ error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ _ in
            self.tabBarController?.selectedIndex = 0
        }
        
        hideActivityIndicator()
        present(alert, animated: true, completion: nil)
    }
    
    func formatted(content: NSAttributedString) -> NSAttributedString
    {
        let range = NSRange(location: 0, length: content.length)
        let font = MMTAppearance.fontWithSize(16)
        
        let
        paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        
        let
        formattedContent = NSMutableAttributedString(attributedString: content)
        formattedContent.addAttribute(.font, value: font, range: range)
        formattedContent.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        return NSAttributedString(attributedString: formattedContent)
    }
}

// MARK: Action extension
fileprivate extension MMTForecasterCommentController
{
    @objc func handleDidBecomeActive(notification: Notification)
    {
        updateTextViewContentIfNeeded()
    }
}
