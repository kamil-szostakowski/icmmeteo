//
//  MMTCitiesListSectionHeader.swift
//  MobileMeteo
//
//  Created by Kamil Szostakowski on 26/12/16.
//  Copyright © 2016 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTCitiesListSectionHeader: UITableViewHeaderFooterView
{    
    @IBOutlet private weak var headerTitle: UILabel!

    override var textLabel: UILabel? {
        return headerTitle
    }

    override func prepareForReuse()
    {
        super.prepareForReuse()
        accessibilityLabel = nil
    }
}
