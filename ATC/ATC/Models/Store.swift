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
    let name: String
    let storeUrl: String
    let imageUrl: String
    let latitude: CGFloat
    let longitutde : CGFloat
    var categories: [Category]
    var isFavorite = false
    let neighbourhood: String
    let description: String
    init(dictionary: Dictionary<String, Any>) {
        self.storeId    = dictionary["id"] as? Int ?? 0
        self.name   = dictionary["shop_name"] as? String ?? ""
        self.storeUrl   = dictionary["store_url"] as? String ?? ""
        self.imageUrl   = dictionary["image"] as? String ?? ""
        self.latitude   = dictionary["latitude"] as? CGFloat ?? 0.0
        self.longitutde = dictionary["longitude"] as? CGFloat ?? 0.0
        self.neighbourhood = dictionary["neighbourhood"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmodtempor incididunt ut labore et doloreincididunt ut labore et dolore Lorem ipsum dolor sit amet, consectetur "
        var categoryArray = [Category]()
        if let categoryDictArray = dictionary["category"] as? Array<Dictionary<String,Any>> {
            for categoryDict in categoryDictArray {
                let category = Category.init(dictionary: categoryDict)
                categoryArray.append(category)
            }
        }
        self.categories = categoryArray
    }
    
//    id = 19;
//    image = "https://lh5.googleusercontent.com/p/AF1QipN9bsT0HkTlHXT2_nts7ffPrM3-kpC8KntwCd--=w408-h229-k-no";
//    latitude = 0;
//    longitude = 0;
//    neighbourhood = "ballard, seattle";
//    "shop_name" = "JOANN Fabrics and Crafts";
//    "store_url" = "stores.joann.com";
}

class Category {
    let categoryId: String
    let name: String
    let imageUrl: String
    let products:[Product]
    init(dictionary: Dictionary<String,Any>) {
        self.categoryId = dictionary["id"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.imageUrl = dictionary["image_url"] as? String ?? ""
        self.products = dictionary["products"] as? Array<Product> ?? [Product]()
    }
}

class Product {
    var productId: Int
    var storeId: Int
    var categoryId: Int
    var categoryName: String
    var name: String
    var price: Float
    var imageUrl: String
    
    init(dictionary: Dictionary<String, Any>) {
        
        self.productId = dictionary["id"] as? Int ?? 0
        self.storeId = dictionary["store_id"] as? Int ?? 0
        self.categoryId = dictionary["category_id"] as? Int ?? 0
        self.name = dictionary["title"] as? String ?? ""
        self.categoryName = dictionary["category_name"] as? String ?? ""
        self.price = dictionary["price"] as? Float ?? 0.0
        self.imageUrl = dictionary["product_image"] as? String ?? ""
    }
//
//    id: 23,
//    store_id: 7,
//    title: "Territory Running Gorge Cap",
//    price: 32,
//    product_image: "http://sevenhillsrunningshop.com/aroundthecorner/img/territory-gorgecap.png",
//    category_id: 1,
//    category_name: "Accessories",
//    category_image: null
}
