//
//  ProductDetailAboutCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 03/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ProductDetailAboutCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var shopCAtegoryImageView: UIImageView!
    @IBOutlet weak var shopLabel: UILabel!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var shopNameContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        callButton.layer.cornerRadius = 4.0
        callButton.layer.borderWidth = 0.75
        callButton.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
