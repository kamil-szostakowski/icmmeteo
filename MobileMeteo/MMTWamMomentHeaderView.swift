//
//  MMTWamMomentHeaderView.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 31.07.2015.
//  Copyright (c) 2015 Kamil Szostakowski. All rights reserved.
//

import UIKit
import Foundation

class MMTWamMomentHeaderView: UITableViewCell
{
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnSelect: UIButton!
    
    override var textLabel: UILabel? { return lblTitle }
    override var isSelected: Bool
    {
        didSet { btnSelect.isSelected = isSelected }
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()

        isSelected = false
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        accessibilityElements = [lblTitle, btnSelect]
    }
    
    @IBAction func didTapSelectButton(_ sender: UIButton)
    {
        isSelected = !isSelected
        
        let action = #selector(MMTModelWamSettingsController.didSelectCategory(_:))
        let target = self.target(forAction: action, withSender: self) as? NSObject
        
        UIApplication.shared.sendAction(action, to: target, from: self, for: nil)

    }
}
