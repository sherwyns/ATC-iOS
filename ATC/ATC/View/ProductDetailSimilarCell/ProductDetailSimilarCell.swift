//
//  ProductDetailSimilarCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani(AWF) on 03/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ProductDetailSimilarCell: UITableViewCell {

    @IBOutlet weak var productCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.productCollectionView.register(UINib.init(nibName: "ProductEntityCell", bundle: nil), forCellWithReuseIdentifier: "ProductEntityCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
