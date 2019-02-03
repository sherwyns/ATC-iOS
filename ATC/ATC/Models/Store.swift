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
    
    func dictionaryFromStoreFavorite() -> Dictionary<String,String> {
        var dictionary = Dictionary<String,String>()
        dictionary["storeid"] = String(self.storeId)
        dictionary["isfavorite"] = String(self.isFavorite)
        
        return dictionary
    }
}

class ProductFavorite {
    let productId: Int
    var isFavorite: Bool
    
    init(dictionary: Dictionary<String, Any>) {
        self.productId    = dictionary["productid"] as? Int ?? 0
        self.isFavorite   = dictionary["isfavorite"] as? Bool ?? false
    }
    
    func dictionaryFromProductFavorite() -> Dictionary<String,String> {
        var dictionary = Dictionary<String,String>()
        dictionary["productid"] = String(self.productId)
        dictionary["isfavorite"] = String(self.isFavorite)
        
        return dictionary
    }
}

class Store {
    let storeId:Int
    let name: String
    let storeUrl: String
    let imageUrl: String
    var latitude: Float
    var longitude : Float
    var categories: [Category]
    var isFavorite = false
    let neighbourhood: String
    var description: String

    init(dictionary: Dictionary<String, Any>) {
        self.storeId    = dictionary["id"] as? Int ?? 0
        self.name   = dictionary["shop_name"] as? String ?? ""
        self.storeUrl   = dictionary["store_url"] as? String ?? ""
        self.imageUrl   = dictionary["image"] as? String ?? ""
        
        if let latitude = dictionary["latitude"] as? Float {
            self.latitude = latitude
        } else if let latitude = dictionary["latitude"] as? Double {
            self.latitude = Float(latitude)
        } else if let latitude = dictionary["latitude"] as? Int {
            self.latitude = Float(latitude)
        } else {
            self.latitude = 0.0
        }
        
        if let longitude = dictionary["longitude"] as? Float {
            self.longitude = longitude
        } else if let longitude = dictionary["longitude"] as? Double {
            self.longitude = Float(longitude)
        } else if let longitude = dictionary["longitude"] as? Int {
            self.longitude = Float(longitude)
        } else {
            self.longitude = 0.0
        }
        
        self.neighbourhood = dictionary["neighbourhood"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
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
    var products:[Product]
    init(dictionary: Dictionary<String,Any>) {
        if let id = dictionary["id"] as? String {
            self.categoryId = id
        }
        else if let id = dictionary["id"] as? Int {
            self.categoryId = String(id)
        }
        else {
            self.categoryId = ""
        }
        
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
    var isFavorite: Bool = false
    var description:String
    
    init(dictionary: Dictionary<String, Any>) {
        
        self.productId = dictionary["id"] as? Int ?? 0
        self.storeId = dictionary["store_id"] as? Int ?? 0
        self.categoryId = dictionary["category_id"] as? Int ?? 0
        self.name = dictionary["title"] as? String ?? ""
        self.categoryName = dictionary["category_name"] as? String ?? ""
        //self.price = dictionary["price"] as? Float ?? 0.0
        
        if let price = dictionary["price"] as? Float {
            self.price = price
        }
        else if let price = dictionary["price"] as? String {
            self.price = 0.0
        }
        else if let price = dictionary["price"] as? Double {
            self.price = Float(price)
        }
        else {
            self.price = 0.0
        }
        
        if let imageUrl = dictionary["product_image"] as? String {
            self.imageUrl = imageUrl
        } else if let imageUrl = dictionary["image"] as? String {
            self.imageUrl = imageUrl
        } else {
            self.imageUrl = ""
        }
        self.description = dictionary["description"] as? String ?? ""
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
