//
//  MMTSlideController.swift
//  MobileMeteo
//
//  Created by szostakowskik on 28/03/2019.
//  Copyright © 2019 Kamil Szostakowski. All rights reserved.
//

import Foundation

class MMTSlideController: UIViewController
{
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        image.layer.cornerRadius = 10
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.8;
        shadowView.layer.shadowRadius = 5.0;
        shadowView.layer.cornerRadius = 20
    }
}
