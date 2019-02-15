//
//  MMTUpdateErrorView.swift
//  MeteoWidget
//
//  Created by szostakowskik on 04.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MeteoModel
import MeteoUIKit

enum MMTUpdateErrorType
{
    case locationServicesUnavailable
    case meteorogramUpdateFailure
}

class MMTUpdateErrorView: UIView
{
    // MARK: Properties
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        awakeFromNib()
    }    
    
    // MARK: Lifecycle methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        addFillingSubview(loadFromNib())
    }
}

extension MMTUpdateErrorView: MMTUpdatableView
{
    func updated(with errorType: MMTUpdateErrorType) -> MMTUpdateErrorView
    {
        var key = ""        
        switch errorType
        {
            case .locationServicesUnavailable: key = "error.widget.locationServicesDisabled"
            case .meteorogramUpdateFailure: key = "error.widget.meteorogramFetchFailure"
        }
                
        descriptionLabel.text = MMTLocalizedString(key)
        return self
    }
}
