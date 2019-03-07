//
//  SegButton.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 19/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class SegButton: UIButton {
    
    var view:UIView?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let _ = view else {
            return
        }
        
        view = UIView.init(frame: self.frame)
        view?.backgroundColor = .white
        self.addSubview(view!)
        self.layer.cornerRadius = 13.5
        let color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.21)
        view!.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 9.0, blur: 14.9, spread: 1.1)
    }
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    func highlightedStateColor() {
        self.layer.cornerRadius = 13.5
        //self.layer.masksToBounds = true
        self.applyGradient(withColours: [ .darkBlue(), .lightBlue()], gradientOrientation: .horizontal)
        self.setTitleColor(.white, for: .normal)
        let color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.21)
        self.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 9.0, blur: 14.9, spread: 1.1)
    }
    
    func normalStateColor() {
        let color = UIColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1)
        self.applyGradient(withColours: [ .white, .white], gradientOrientation: .horizontal)
        self.setTitleColor(color, for: .normal)
//        if let sublayers = self.layer.sublayers, sublayers.count >= 1 {
//            sublayers[0].removeFromSuperlayer()
//        }
        self.layer.applySketchShadow(color: .clear, alpha: 1, x: 0.0, y: 9.0, blur: 14.9, spread: 1.1)
    }

}
