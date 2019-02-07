//
//  ProductEntityCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 02/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ProductEntityCell: UICollectionViewCell {
    static let kPRODUCT_ENTITY_CELL = "ProductEntityCell"
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoritebutton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
        bannerImageView.layer.cornerRadius = 5.0
        bannerImageView.layer.masksToBounds = true
        self.layer.masksToBounds = true
        let color = UIColor.init(red: 144.0/255.0, green: 144.0/255.0, blue: 144.0/255.0, alpha: 0.21)
        self.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 3.0, blur: 14.9, spread: 1.1)
        
        favoritebutton.layer.cornerRadius = 35.0 / 2
        favoritebutton.layer.masksToBounds = true
        favoritebutton.imageEdgeInsets = UIEdgeInsets(top: 8, left:8, bottom: 8, right: 8)
        
        callButton.layer.cornerRadius = 4.0
        callButton.layer.borderWidth = 0.75
        callButton.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func showPriceOrCallbutton(price: Float) {
        if price == 0.0 {
            callButton.isHidden = false
            priceLabel.isHidden = true
        }
        else if price == 0 {
            callButton.isHidden = false
            priceLabel.isHidden = true
        }
        else {
            callButton.isHidden = true
            priceLabel.isHidden = false
        }
    }
    

}
