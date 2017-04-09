//
//  CustomSlider.swift
//  LocationLoktra
//
//  Created by Saurabh Yadav on 09/04/17.
//  Copyright © 2017 Saurabh Yadav. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var trackHeight: CGFloat = 30

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize.init(width: bounds.width, height: trackHeight))
    }
}
