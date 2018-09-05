//
//  MMTUpdateErrorView.swift
//  MeteoWidget
//
//  Created by szostakowskik on 04.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MeteoModel

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
        switch errorType {            
            case .locationServicesUnavailable:
                iconImageView.image = #imageLiteral(resourceName: "ext-detailed-maps")
                descriptionLabel.text = "Usługi lokalizacyjne są niedostępne."
            case .meteorogramUpdateFailure:
                iconImageView.image = #imageLiteral(resourceName: "ext-detailed-maps")
                descriptionLabel.text = "Nie udało się pobrać meteorogramu."
        }
        return self
    }
}
