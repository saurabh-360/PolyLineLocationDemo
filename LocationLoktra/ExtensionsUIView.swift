//
//  ExtensionsUIView.swift
//  LocationLoktra
//
//  Created by Saurabh Yadav on 09/04/17.
//  Copyright © 2017 Saurabh Yadav. All rights reserved.
//

import UIKit

class ExtensionsUIView: NSObject {

}

extension UIView {
    
    func addShadowView(width:CGFloat=0.0, height:CGFloat=1.0, Opacidade:Float=0.7, maskToBounds:Bool=false, radius:CGFloat=4.0) {
        // corner radius
        self.layer.cornerRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5.0
        self.layer.masksToBounds = false
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        self.layer.masksToBounds = true
    }
}
