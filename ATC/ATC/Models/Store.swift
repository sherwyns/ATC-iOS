//
//  Store.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 19/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import UIKit

class StoreFavorite {
    let storeId: Int
    var isFavorite: Bool
    
    init(dictionary: Dictionary<String, Any>) {
        self.storeId    = dictionary["storeid"] as? Int ?? 0
        self.isFavorite   = dictionary["isfavorite"] as? Bool ?? false
    }
}

class Store {
    let storeId:Int
    let shopName: String
    let storeUrl: String
    let imageUrl: String
    let latitude: CGFloat
    let longitutde : CGFloat
    let categories: [Category]
    var isFavorite = false
    let neighbourhood: String
    
    init(dictionary: Dictionary<String, Any>) {
        self.storeId    = dictionary["id"] as? Int ?? 0
        self.shopName   = dictionary["shop_name"] as? String ?? ""
        self.storeUrl   = dictionary["store_url"] as? String ?? ""
        self.imageUrl   = dictionary["image"] as? String ?? ""
        self.latitude   = dictionary["latitude"] as? CGFloat ?? 0.0
        self.longitutde = dictionary["longitude"] as? CGFloat ?? 0.0
        self.neighbourhood = dictionary["neighbourhood"] as? String ?? ""
        
        var categoryArray = [Category]()
        if let categoryDictArray = dictionary["category"] as? Array<Dictionary<String,Any>> {
            for categoryDict in categoryDictArray {
                let category = Category.init(dictionary: categoryDict)
                categoryArray.append(category)
            }
        }
        self.categories = categoryArray
        
    }
}

class Category {
    let categoryId: String
    let name: String
    let imageUrl: String
    
    init(dictionary: Dictionary<String,Any>) {
        self.categoryId = dictionary["id"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.imageUrl = dictionary["image_url"] as? String ?? ""
    }
}
