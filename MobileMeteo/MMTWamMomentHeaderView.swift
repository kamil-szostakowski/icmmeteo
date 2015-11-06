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
    override var selected: Bool
    {
        didSet { btnSelect.selected = selected }
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()

        selected = false
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        accessibilityElements = [lblTitle, btnSelect]
    }
    
    @IBAction func didTapSelectButton(sender: UIButton)
    {
        selected = !selected
        
        let action = Selector("didSelectCategory:")
        let target = targetForAction(action, withSender: self) as? NSObject
        
        UIApplication.sharedApplication().sendAction(action, to: target, from: self, forEvent: nil)

    }
}