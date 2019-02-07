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
    var storeUrl: String
    let imageUrl: String
    var latitude: Float
    var longitude : Float
    var categories: [Category]
    var isFavorite = false
    let neighbourhood: String
    var description: String
    var phoneNumber: String
    var address: String
    var state: String
    var city: String
    var zipcode: String
    var workinghours: String
    
    init(dictionary: Dictionary<String, Any>) {
        self.storeId     = dictionary["id"] as? Int ?? 0
        self.name        = dictionary["shop_name"] as? String ?? ""
        self.storeUrl    = dictionary["store_url"] as? String ?? ""
        self.imageUrl    = dictionary["image"] as? String ?? ""
        self.phoneNumber = dictionary["phonenumber"] as? String ?? ""
        self.address = dictionary["address"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.zipcode = dictionary["zipcode"] as? String ?? ""
        self.workinghours = dictionary["workinghours"] as? String ?? ""
        
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
}

extension Store {
    func fullAddress() -> String {
        var addressComponentArray = [String]()
        if self.address.count > 0 {
            addressComponentArray.append(address)
        }
        if self.city.count > 0 {
            addressComponentArray.append(city)
        }
        if self.state.count > 0 {
            addressComponentArray.append(state)
        }
        if self.zipcode.count > 0 {
            addressComponentArray.append(zipcode)
        }
        
        var finalAddress = String()
        
        if addressComponentArray.count == 1 {
            return addressComponentArray.first!
        }
        else {
            for component in addressComponentArray {
                
                if let firstComponent = addressComponentArray.first, component == firstComponent {
                    finalAddress = component
                }
                else {
                    finalAddress = finalAddress + ", " + component
                }
            }
        }
        
        return finalAddress
    }
    
    func workingHours() -> String {
        if let data = self.workinghours.data(using: .utf8) {
            do {
                if let workingHourDictionary = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any> {
                    print(workingHourDictionary) // use the json here
                    
                    if let dayWorkingHourDictionary = workingHourDictionary[Date.dayOfWeek()] as? Dictionary<String,String>, let endTime = dayWorkingHourDictionary["endTime"] {
                        return "Open until " + endTime
                    }
                    else {
                        return String()
                    }
                }
                else {
                    return String()
                }
            } catch let error as NSError {
                print(error)
                return String()
            }
        }
        return String()
    }
    
    func storeCategoryImageUrlString() -> String {
        
        if let category = self.categories.first {
            return category.imageUrl
        }
        
        return String()
    }
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


//["sunday": {
//    endTime = "05:00PM";
//    startTime = "09:00AM";
//    }, "friday": {
//        endTime = "05:00PM";
//        startTime = "09:00AM";
//    }, "tuesday": {
//        endTime = "05:00PM";
//        startTime = "09:00AM";
//    }, "saturday": {
//        endTime = "05:00PM";
//        startTime = "09:00AM";
//    }, "monday": {
//        endTime = "05:00PM";
//        startTime = "09:00AM";
//    }, "wednesday": {
//        endTime = "05:00PM";
//        startTime = "09:00AM";
//    }, "thursday": {
//        endTime = "05:00PM";
//        startTime = "09:00AM";
//    }]
enum weekday: String {
    case sunday    = "sunday"
    case monday    = "monday"
    case tuesday   = "tuesday"
    case wednesday = "wednesday"
    case thursday  = "thursday"
    case friday    = "friday"
    case saturday  = "saturday"
}

public func dayOfTheWeek() -> String {
    
    return String()
}

extension Date {
    static func dayOfWeek() -> String {
        
        let daysArray = ["sunday",
                         "monday",
                         "tuesday",
                         "wednesday",
                         "thursday",
                         "friday",
                         "saturday"]
        
        return daysArray[Calendar.current.component(.weekday, from: Date()) - 1]
    }
}
