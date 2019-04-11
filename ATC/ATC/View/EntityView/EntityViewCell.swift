//
//  EntityViewCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 19/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class EntityViewCell: UICollectionViewCell {
  @IBOutlet weak var bannerImageView: UIImageView!
  @IBOutlet weak var favoritebutton: UIButton!
  @IBOutlet weak var categoryImageView: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var subName: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        let color = UIColor.init(red: 144.0/255.0, green: 144.0/255.0, blue: 144.0/255.0, alpha: 0.21)
        self.layer.applySketchShadow(color: color, alpha: 1, x: 0.0, y: 3.0, blur: 14.9, spread: 1.1)
      
        favoritebutton.layer.cornerRadius = 35.0 / 2
        favoritebutton.layer.masksToBounds = true
        favoritebutton.imageEdgeInsets = UIEdgeInsets(top: 8, left:8, bottom: 8, right: 8)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = ""
        subName.text = ""
        bannerImageView.image = UIImage.init(named: "placeholder")
    }

}
