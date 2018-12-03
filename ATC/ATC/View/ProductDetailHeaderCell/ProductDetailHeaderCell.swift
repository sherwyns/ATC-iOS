//
//  ProductDetailHeaderCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani(AWF) on 03/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ProductDetailHeaderCell: UITableViewCell {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet weak var favoritebutton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor.init(red: 144.0/255.0, green: 144.0/255.0, blue: 144.0/255.0, alpha: 0.21)
    
        productImageView.layer.cornerRadius = 8.0
        productImageView.layer.masksToBounds = true
        productImageView.layer.borderColor = UIColor.lightGray.cgColor
        productImageView.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 3.0, blur: 14.9, spread: 1.1)
        self.backgroundColor = .clear
        
        favoritebutton.layer.cornerRadius = 35.0 / 2
        favoritebutton.layer.masksToBounds = true
        favoritebutton.imageEdgeInsets = UIEdgeInsets(top: 8, left:8, bottom: 8, right: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
