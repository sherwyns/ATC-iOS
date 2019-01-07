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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
