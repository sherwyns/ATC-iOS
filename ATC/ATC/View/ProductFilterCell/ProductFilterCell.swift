//
//  ProductFilterCell.swift
//  ATC
//
//  Created by DHANDAPANI R on 06/05/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ProductFilterCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var selectionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionImageView.tintColor = UIColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0)
        categoryLabel.text = ""
    }
    
}
