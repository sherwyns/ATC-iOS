//
//  ProductFilterSectionView.swift
//  ATC
//
//  Created by DHANDAPANI R on 05/05/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ProductFilterSectionView: UITableViewHeaderFooterView {
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var fullTapButton: UIButton!
    @IBOutlet weak var selectionImageView: UIImageView!
    
    override var reuseIdentifier: String? {
        return "ProductFilterSectionView"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBadgeView()
    }

    override func prepareForReuse() {
        expandButton.tintColor = UIColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0)
        selectionImageView.tintColor = UIColor.init(red: 120.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0)
        categoryLabel.text = ""
    }
    
    fileprivate func setupBadgeView() {
        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height / 2
        badgeLabel.layer.masksToBounds = true
        badgeLabel.backgroundColor = .orange
        badgeLabel.textColor = .white
        badgeLabel.isHidden = false
        badgeLabel.text = "10"
    }
}
