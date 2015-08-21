//
//  MMTWamCategoryItem.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 20.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTWamCategoryItem: UICollectionViewCell
{
    @IBOutlet var map: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var footerLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        map.addObserver(self, forKeyPath: "image", options: .New, context: nil)
    }
    
    override func prepareForReuse()
    {
        map.image = nil
        headerLabel.text = ""
        footerLabel.text = ""
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>)
    {
        if keyPath == "image" {
            enableActivityIndicator(change["new"] is NSNull)
        }
    }
    
    deinit
    {
        map.removeObserver(self, forKeyPath: "image")
    }
    
    // MARK: Helper methods
    
    private func enableActivityIndicator(enabled: Bool)
    {
        activityIndicator.hidden = !enabled
        
        if enabled { activityIndicator.startAnimating() }
        else {
            activityIndicator.stopAnimating()
        }
    }
}