//
//  CategoryHighlightCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 30/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class CategoryHighlightCell: UICollectionViewCell {
    
    let color = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.21)
    
    @IBOutlet var typeLabel: UILabel!
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 9.0, blur: 14.9, spread: 1.1)
        self.layer.cornerRadius = 13.5
    }
    
    func applySelection() {
        self.applyGradient(withColours: [.darkBlue(), .lightBlue()], gradientOrientation: .horizontal)
        self.typeLabel.textColor = .white
    }
    
    func applyNormalState() {
        self.applyGradient(withColours: [.white, .white], gradientOrientation: .horizontal)
        self.typeLabel.textColor = .black
    }

}
