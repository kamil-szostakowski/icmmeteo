//
//  MMTForecasterCommentController.swift
//  MobileMeteo
//
//  Created by szostakowskik on 20.02.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import MeteoModel
import MeteoUIKit

class MMTForecasterCommentController: UIViewController, MMTActivityIndicating
{
    // MARK: Outlets
    @IBOutlet weak var textView: UITextView!
    
    var activityIndicator: MMTActivityIndicator!
    var modelController: MMTForecasterCommentModelController!
    
    // MARK: Lifecycle methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupModelController()
        setupTextView(content: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        setupNotificationHandler()
        modelController.activate()
        analytics?.sendScreenEntryReport(MMTAnalyticsCategory.ForecasterComment.rawValue)
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
    func setupModelController()
    {
        modelController = MMTForecasterCommentModelController(dataStore: MMTForecasterCommentStore())
        modelController.delegate = self
    }
    
    func setupTextView(content: NSAttributedString?)
    {
        textView.attributedText = content
        textView.contentOffset = .zero
        textView.isUserInteractionEnabled = content != nil
    }
    
    func setupNotificationHandler()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    func displayErrorAlert(_ error: MMTError)
    {
        let alert = UIAlertController.alertForMMTError(error){ _ in
            self.tabBarController?.selectedIndex = 0
        }
        
        hideActivityIndicator()
        present(alert, animated: true, completion: nil)
    }
    
    func setActivityIndicator(visible: Bool)
    {
        switch visible {
            case true: displayActivityIndicator(in: view, message: MMTLocalizedString("label.loading.comment"))
            case false: hideActivityIndicator()
        }
    }
}

fileprivate extension MMTForecasterCommentController
{
    // MARK: Action extension
    @objc func handleDidBecomeActive(notification: Notification)
    {
        modelController.activate()
    }
}

extension MMTForecasterCommentController: MMTModelControllerDelegate
{
    // MARK: Data update methods
    func onModelUpdate(_ controller: MMTModelController)
    {
        setActivityIndicator(visible: modelController.requestPending)
        
        if let error = modelController.error {
            displayErrorAlert(error)
            return
        }
        
        setupTextView(content: modelController.comment)
    }
}
