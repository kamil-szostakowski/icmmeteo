//
//  MMTForecastDescription.swift
//  MeteoWidget
//
//  Created by szostakowskik on 04.07.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import MeteoModel

class MMTForecastDescriptionView: UIView
{
    struct ViewModel
    {
        var icon: UIImage
        var startDateText: String
        var descriptionText: String
    }
    
    // MARK: Properties
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
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
        
        return self
    }
}

extension MMTForecastDescriptionView.ViewModel
{
    init(_ prediction: MMTMeteorogram.Prediction)
    {
        let startDate = DateFormatter.utcFormatter.string(from: Date()) // FIXME: Wrong date !!!
        var iconImage = #imageLiteral(resourceName: "ext-sunny")
        
        var
        components = [String]()
        components.append(prediction.contains(.clouds) ? "pochmurnie" : "słonecznie")
        
        if prediction.contains(.strongWind) {
            components.append("silny wiatr")
            iconImage = #imageLiteral(resourceName: "ext-wind")
        }
        
//        if prediction.storm > treshold {
//            components.append("\nmożliwe burze")
//            iconImage = #imageLiteral(resourceName: "ext-storm")
//        } else if prediction.rain > treshold && prediction.snow > treshold {
//            if components.count == 2 { components.remove(at: 0) }
//            components.append("możliwe opady deszczu ze śniegiem")
//            iconImage = #imageLiteral(resourceName: "ext-snow")
        
        if prediction.contains(.rain) {
            components.append("\nmożliwe opady deszczu")
            iconImage = #imageLiteral(resourceName: "ext-rain")
        }
//        else if prediction.snow > treshold {
//            components.append("\nmożliwe opady śniegu")
//            iconImage = #imageLiteral(resourceName: "ext-snow")
//        }
        
        icon = iconImage
        startDateText = "Start prognozy: \(startDate)"
        descriptionText = components.joined(separator: ", ")
    }
}
