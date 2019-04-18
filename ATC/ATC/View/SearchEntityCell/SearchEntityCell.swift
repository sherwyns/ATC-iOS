//
//  SearchEntityCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 16/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class SearchEntityCell: UITableViewCell {
    
    @IBOutlet weak var collectionView:UICollectionView!

    let kENTITY_VIEW = "EntityViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.register(UINib.init(nibName: kENTITY_VIEW, bundle: nil), forCellWithReuseIdentifier: kENTITY_VIEW)
        self.collectionView.register(UINib.init(nibName: ProductEntityCell.kPRODUCT_ENTITY_CELL, bundle: nil), forCellWithReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
}
