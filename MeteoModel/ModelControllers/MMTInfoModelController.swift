//
//  MMTInfoModelController.swift
//  MeteoModel
//
//  Created by szostakowskik on 22.08.2018.
//  Copyright © 2018 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

public class MMTInfoModelController: MMTModelController
{
    // MARK: Properties
    public var weatherIconsCredit: NSMutableAttributedString
    public var qaSupportCredit: NSMutableAttributedString
    public var authorCredit: NSMutableAttributedString
    
    public var feedbackEmailTopic: String
    public var feedbackEmailRecipient: String
    
    fileprivate var creditFont: UIFont
    
    // MARK: Initializers
    public init(font: UIFont)
    {
        creditFont = font
        feedbackEmailTopic = "ICM Meteo, Feedback"
        feedbackEmailRecipient = "meteo.contact1@gmail.com"
        
        weatherIconsCredit = NSMutableAttributedString(string: "The Weather is Nice Today / Laura Reen / CC BY-NC 3.0")
        authorCredit = NSMutableAttributedString(string: "Kamil Szostakowski / GitHub / Stack Overflow")
        qaSupportCredit = NSMutableAttributedString(string: "Bartosz Świeżawski")
        
        super.init()
        setupCreditsUrls()
    }
    
    // MARK: Lifecycle methods
    public override func activate()
    {
        delegate?.onModelUpdate(self)
    }
}

extension MMTInfoModelController
{
    // MARK: Setup methods
    fileprivate func setupCreditsUrls()
    {
        weatherIconsCredit.addAttribute(.font, value: creditFont)
        weatherIconsCredit.set(url: CreditsURL.iconsSet, for: "The Weather is Nice Today")
        weatherIconsCredit.set(url: CreditsURL.iconsAuthor, for: "Laura Reen")
        weatherIconsCredit.set(url: CreditsURL.iconsLicense, for: "CC BY-NC 3.0")
        
        qaSupportCredit.addAttribute(.font, value: creditFont)
        qaSupportCredit.set(url: CreditsURL.qaSupport, for: "Bartosz Świeżawski")
        
        authorCredit.addAttribute(.font, value: creditFont)
        authorCredit.set(url: CreditsURL.authorLinkedIt, for: "Kamil Szostakowski")
        authorCredit.set(url: CreditsURL.authorGithub, for: "GitHub")
        authorCredit.set(url: CreditsURL.authorStackOverflow, for: "Stack Overflow")
    }
}

fileprivate struct CreditsURL
{
    static let iconsSet = "https://www.iconfinder.com/iconsets/the-weather-is-nice-today"
    static let iconsAuthor = "https://www.iconfinder.com/laurareen"
    static let iconsLicense = "https://creativecommons.org/licenses/by-nc/3.0/deed.en"
    static let qaSupport = "https://www.linkedin.com/in/bartosz-%C5%9Bwie%C5%BCawski-046781b3/"
    static let authorLinkedIt = "https://www.linkedin.com/in/kamil-szostakowski-407080a2/"
    static let authorGithub = "https://github.com/kamil-szostakowski"
    static let authorStackOverflow = "https://stackoverflow.com/users/1692080/kamil-szostakowski"
}

