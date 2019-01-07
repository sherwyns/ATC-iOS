//
//  StoreDetailViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 30/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

enum StoreDetailCell {
    case Header
    case Detail
    case Map
}

class StoreDetailViewController: UIViewController {
    
    @IBOutlet weak var productButton: SegButton!
    
    let cellArray: [StoreDetailCell] = [.Header, .Detail, .Map]
    let kStoreDetailHeaderCell = "StoreDetailHeaderCell"
    let kStoreDetailAboutCell = "StoreDetailAboutCell"
    let kStoreDetailMapCell = "StoreDetailMapCell"
    
    let grayColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    var store:Store!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellForTableView()
        
        self.tableView.backgroundColor = grayColor
        self.view.backgroundColor = grayColor
        
        productButton.makeRoundedCorner()
        productButton.backgroundColor = UIColor.orange
    }
    
    func registerCellForTableView() {
        self.tableView.register(UINib.init(nibName: kStoreDetailHeaderCell, bundle: nil), forCellReuseIdentifier: kStoreDetailHeaderCell)
        self.tableView.register(UINib.init(nibName: kStoreDetailAboutCell, bundle: nil), forCellReuseIdentifier: kStoreDetailAboutCell)
        self.tableView.register(UINib.init(nibName: kStoreDetailMapCell, bundle: nil), forCellReuseIdentifier: kStoreDetailMapCell)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.contentInset = UIEdgeInsets.init(top: 5, left: 0, bottom: 100, right: 0)
    }
    
    @IBAction func showProducts()  {
        self.backAction()
    }
}

extension StoreDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellArray[indexPath.row]
        
        switch cellType {
        case .Header:
            let headerCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailHeaderCell) as! StoreDetailHeaderCell
            if let imageUrl = URL.init(string: store.imageUrl) {
                headerCell.shopImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "placeholder"))
            }
            
            if self.store.isFavorite {
                headerCell.favoriteButton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }else {
                headerCell.favoriteButton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
            headerCell.shopLabel.text = store.name
            return headerCell
        case .Detail:
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailAboutCell) as! StoreDetailAboutCell
            aboutCell.descriptionLabel.text = store.description
            return aboutCell
        case .Map:
            let mapCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailMapCell) as! StoreDetailMapCell
            return mapCell
        }
    }
}

extension StoreDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellArray[indexPath.row]
        
        switch cellType {
        case .Header:
            return 263
        case .Detail:
            let maxLabelWidth: CGFloat = self.view.frame.size.width - 16
            let aboutCell = self.tableView.dequeueReusableCell(withIdentifier: kStoreDetailAboutCell) as! StoreDetailAboutCell
            aboutCell.descriptionLabel.text = store.description
            let neededSize = aboutCell.descriptionLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
            return 115 + neededSize.height
        case .Map:
            return 173
        }
    }
}

