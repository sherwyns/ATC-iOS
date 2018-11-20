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
        // Do any additional setup after loading the view.
    }
}

extension EntityViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch entityType {
    case .Product:
        return products?.count ?? 0
    case .Store:
        return stores?.count ?? 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: kENTITY_VIEW, for: indexPath) as? EntityViewCell
    
    switch entityType {
    case .Product:
        //if let store = storeForIndexPath(indexPath) {
            cell?.name.text = "Product"
            cell?.subName.text = "neighbourhood"
        //}
        break
    case .Store:
        if let store = storeForIndexPath(indexPath.row) {
            cell?.name.text = store.shopName.capitalizeFirst
            cell?.subName.text = store.neighbourhood
            cell?.favoritebutton.tag = indexPath.row
            cell?.favoritebutton.addTarget(self, action: #selector(EntityViewController.updateFavorite(sender:)), for: .touchUpInside)
            if !store.isFavorite {
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
    }
    
    
    return cell ?? UICollectionViewCell()
  }
    
    @objc @IBAction func updateFavorite(sender: UIButton) {
        
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
}

extension EntityViewController: UICollectionViewDelegateFlowLayout {
  
}
