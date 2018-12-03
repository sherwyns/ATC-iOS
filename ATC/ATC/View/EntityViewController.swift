//
//  EntityViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 18/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

enum EntityType {
    case Store
    case Product
}

class EntityViewController: UIViewController {
    
    let kLEFT_INSET = 8.0
    let kRIGHT_INSET = 8.0
    
    var isFiltered = false
    var kWIDTH_CELL: CGFloat {
        let insettedWidth = Int((self.view.frame.size.width - 24))
        if (insettedWidth%2) == 0 {
            return CGFloat(insettedWidth / 2)
        }
        else {
           return CGFloat((insettedWidth - 1) / 2)
        }
        
    }
    
    var entityType = EntityType.Store
    
    @IBOutlet var collectionView: UICollectionView!
    
    let kENTITY_VIEW = "EntityViewCell"
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 50.0, right: 8.0)
    
    var stores: [Store]? {
        didSet {
            //self.collectionView.reloadData()
        }
    }
    
    var products: [Store]? {
        didSet {
            //self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: kENTITY_VIEW, bundle: nil), forCellWithReuseIdentifier: kENTITY_VIEW)
        self.collectionView.register(UINib.init(nibName: ProductEntityCell.kPRODUCT_ENTITY_CELL, bundle: nil), forCellWithReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFiltered {
            self.stores = SharedObjects.shared.storesForFavorite
        }
        else {
            self.stores = SharedObjects.shared.stores
        }
        self.collectionView.reloadData()
    }
}

extension EntityViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch entityType {
    case .Product:
        return products?.count ?? 20
    case .Store:
        return stores?.count ?? 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    
    switch entityType {
    case .Product:
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ProductEntityCell.kPRODUCT_ENTITY_CELL, for: indexPath) as? ProductEntityCell
            cell?.nameLabel.text = "Product"
            cell?.priceLabel.text = "$12"
        return cell ?? UICollectionViewCell()
    case .Store:
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: kENTITY_VIEW, for: indexPath) as? EntityViewCell
        if let store = storeForIndexPath(indexPath.row) {
            cell?.name.text = store.shopName.capitalizeFirst
            cell?.subName.text = store.neighbourhood
            if let imageUrl = URL.init(string: store.imageUrl) {
                cell?.bannerImageView.setImageWith(imageUrl, placeholderImage: UIImage.init(named: "pep-pizza"))
            }
            
            cell?.favoritebutton.tag = indexPath.row
            cell?.favoritebutton.addTarget(self, action: #selector(EntityViewController.updateFavorite(sender:)), for: .touchUpInside)
            if store.isFavorite {
                cell?.favoritebutton.setImage(UIImage.init(named: "favorite"), for: .normal)
            }
            else {
                cell?.favoritebutton.setImage(UIImage.init(named: "unfavorite"), for: .normal)
            }
        }
        else {
            cell?.name.text = "Product"
            cell?.subName.text = "neighbourhood"
        }
        return cell ?? UICollectionViewCell()
    }
  }
    
    @objc @IBAction func updateFavorite(sender: UIButton) {
        
        if !ATCUserDefaults.isUserLoggedIn() {
            //entityContainer.isHidden = true
            showLogInAlert()
            return
        }
        
        if let stores = self.stores {
            let selectedStore = stores[sender.tag]
            SharedObjects.shared.updateWithNewOrExistingStoreId(selectedStore: selectedStore)
        }
        if isFiltered {
            self.stores = SharedObjects.shared.storesForFavorite
        }
        else {
            self.stores = SharedObjects.shared.stores
        }
        
        self.collectionView.reloadData()
    }
  
    func storeForIndexPath(_ row: Int) -> Store? {
        if let stores = self.stores {
            return stores[row]
        }
        return nil
    }
    
    func productForIndexPath(_ indexPath: IndexPath) -> Store? {
        if let stores = self.stores {
            return stores[indexPath.row]
        }
        return nil
    }
}

extension EntityViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: kWIDTH_CELL, height: kWIDTH_CELL)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch entityType {
        case .Store:
            self.parent?.performSegue(withIdentifier: "showStore", sender: nil)
        case .Product:
            self.parent?.performSegue(withIdentifier: "showProductDetail", sender: nil)
        }
    }
}

extension EntityViewController: UICollectionViewDelegateFlowLayout {
  
}
