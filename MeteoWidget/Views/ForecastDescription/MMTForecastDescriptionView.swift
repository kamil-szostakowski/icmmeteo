//
//  MMTForecastDescription.swift
//  MeteoWidget
//
//  Created by szostakowskik on 04.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MeteoModel
import MeteoUIKit

class MMTForecastDescriptionView: UIView
{
    struct ViewModel
    {
        var icon: UIImage
        var startDateText: String
        var descriptionText: String
        var city: String
    }
    
    // MARK: Properties
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
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

extension MMTForecastDescriptionView: MMTUpdatableView
{
    func updated(with description: MMTForecastDescriptionView.ViewModel) -> MMTForecastDescriptionView
    {
        iconImageView.image = description.icon
        startDateLabel.text = description.startDateText
        descriptionLabel.text = description.descriptionText
        cityNameLabel.text = description.city
        
        return self
    }
}

extension MMTForecastDescriptionView.ViewModel
{
    init?(_ meteorogram: MMTMeteorogram)
    {
        let startDate = DateFormatter.utcFormatter.string(from: meteorogram.startDate)
        
        startDateText = MMTLocalizedStringWithFormat("widget.forecast.start: %@", startDate)
        city = meteorogram.city.name
        descriptionText = ""
        icon = #imageLiteral(resourceName: "logo2")
        
        if let prediction = meteorogram.prediction {
            icon = image(for: prediction)
            descriptionText = text(for: prediction)
        }
    }
    
    private func image(for prediction: MMTMeteorogram.Prediction) -> UIImage
    {
        if prediction.contains(.snow) { return #imageLiteral(resourceName: "ext-snow") }
        if prediction.contains(.rain) { return #imageLiteral(resourceName: "ext-rain") }
        if prediction.contains(.strongWind) { return #imageLiteral(resourceName: "ext-wind") }
        if prediction.contains(.clouds) { return #imageLiteral(resourceName: "ext-cloudy") }
        
        return #imageLiteral(resourceName: "ext-sunny")
    }
    
    private func text(for prediction: MMTMeteorogram.Prediction) -> String
    {
        var components = [String]()
        
        if prediction.contains(.clouds) {
            components.append("widget.cloudy")
        } else {
            components.append("widget.sunny")
        }
        
        if prediction.contains(.strongWind) {
            components.append("widget.windy")
        }
        
        if prediction.contains(.rain) {
            components.append("widget.rainy")
        }
        else if prediction.contains(.snow) {
            components.append("widget.snowy")
        }
        
        return components
            .map { MMTLocalizedString($0) }
            .joined(separator: ", ")
    }
}
