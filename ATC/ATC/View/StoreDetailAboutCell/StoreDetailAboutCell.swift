//
//  StoreDetailAboutCell.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 01/12/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class StoreDetailAboutCell: UITableViewCell {
    
    @IBOutlet weak var callButton:SegButton!
    @IBOutlet weak var mailButton:SegButton!
    @IBOutlet weak var globeButton:SegButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var workingHourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        callButton.highlightedStateColor()
        mailButton.highlightedStateColor()
        globeButton.highlightedStateColor()
        
        
        callButton.layer.cornerRadius = 24.5
        mailButton.layer.cornerRadius = 24.5
        globeButton.layer.cornerRadius = 24.5
        
       callButton.applyGradient(withColours: [UIColor.lightBlue(), UIColor.darkBlue()], gradientOrientation: .vertical)
        mailButton.applyGradient(withColours: [UIColor.lightBlue(), UIColor.darkBlue()], gradientOrientation: .vertical)
        globeButton.applyGradient(withColours: [UIColor.lightBlue(), UIColor.darkBlue()], gradientOrientation: .vertical)
        
        callButton.imageEdgeInsets = UIEdgeInsets(top: 10, left:10, bottom: 10, right: 10)
        mailButton.imageEdgeInsets = UIEdgeInsets(top: 10, left:10, bottom: 10, right: 10)
         globeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left:10, bottom: 10, right: 10)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
