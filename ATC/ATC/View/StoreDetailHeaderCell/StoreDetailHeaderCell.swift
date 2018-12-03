//
//  StoreDetailHeaderCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 01/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class StoreDetailHeaderCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var storeContainer: UIView!
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var shopSubLabel: UILabel!
    @IBOutlet weak var shopCategoryImageView: UIImageView!
    @IBOutlet weak var shopImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favoriteButton.layer.cornerRadius = 35.0 / 2
        favoriteButton.layer.backgroundColor = UIColor.white.cgColor
        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 8, left:8, bottom: 8, right: 8)
        favoriteButton.layer.borderColor = UIColor.lightGray.cgColor
        
        let color = UIColor.init(red: 144.0/255.0, green: 144.0/255.0, blue: 144.0/255.0, alpha: 0.21)
        favoriteButton.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 3.0, blur: 14.9, spread: 1.1)
        
        container.layer.cornerRadius = 8.0
        container.layer.masksToBounds = true
        container.layer.borderColor = UIColor.lightGray.cgColor
        container.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 3.0, blur: 14.9, spread: 1.1)
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
