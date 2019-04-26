//
//  SharedObjects.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 20/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
class SharedObjects{
    
    static let shared = SharedObjects()
    
    var stores: [Store]?
    
    var products: [Product]?
    
    var storesWithFavorite: [Store]?
    
    var favStores: [StoreFavorite]?
    
    var favProducts: [ProductFavorite]?
 
    var categories: [Category] = [Category]()
    
    var categoryId: String?
    
    var categoryIds = [String]()
    
    var neighbourhoods = [String]()
    
    var canReloadStore: Bool = true
    
    var location: CLLocation?
    
    private init(){
       //ATCUserDefaults.retrieveFavProductStore()
    }
    
    func getStoresWithFavorite(completionHandler: @escaping ([Store]?) -> Void) {
        var storeWithOutFavoriteArray = [Store]()
        var storeWithFavoriteArray = [Store]()
        let storeUrlString = ApiServiceURL.apiInterface(.getStores)
        Downloader.getStoreJSONUsingURLSession(url: storeUrlString) { (result, errorString) in
            if let _ = errorString {
                completionHandler(nil)
            }
            else {
                //print(result)
                if let result = result, let storeDictionaryArray = result["data"] as? Array<Dictionary<String, Any>> {
                    for storeDictionary in storeDictionaryArray {
                        let store = Store.init(dictionary: storeDictionary)
                        storeWithOutFavoriteArray.append(store)
                    }
                }
                
                if let userId = ATCUserDefaults.userId() {
                    
                    var brandNewStoresWithFavoriteDate = [Store]()
                    
                    self.getFavoriteStoreIdForUserId(userId, completionHandler: { (storeFavoriteKeyArray) in
                        if let storeFavoriteKeys = storeFavoriteKeyArray {
                            for storeFavoriteKey in storeFavoriteKeys {
                                for storeWithOutFavorite in storeWithOutFavoriteArray {
                                    if storeFavoriteKey.storeId == storeWithOutFavorite.storeId {
                                        storeWithOutFavorite.isFavorite = false
                                    }
                                }
                            }
                        }
                        storeWithFavoriteArray = storeWithOutFavoriteArray
                        completionHandler(storeWithFavoriteArray)
                    })
                }
                else {
                    completionHandler(storeWithOutFavoriteArray)
                }
                
                
            }
        }
    }
    
    func getFavoriteStoreIdForUserId(_ id: String, completionHandler: @escaping ([StoreFavorite]?) -> Void) {
        let scheme = "http"
        let host = "34.209.125.112"
        let path = "/api/favorites/findOne"
        let queryItem = URLQueryItem(name: "filter", value: "{\"where\":{\"user_id\":\(id)}}")
        
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = [queryItem]
        
        if let url = urlComponents.url {
            //print(url)   // "https://www.google.com/search?q=Formula%20One"
            
            Downloader.getStoreJSONUsingURLSession(serviceUrl: url) { (result, errorString) in
                if let error = errorString {
                    completionHandler(nil)
                }
                else {
                    //print(result)
                    
                    if let result = result, let storeFavDictionaryArray = result["store"] as? Array<Dictionary<String, Any>> {
                        //print(storeFavDictionaryArray)
                        var favOnlyArray = [StoreFavorite]()
                        for storeFavDictionary in storeFavDictionaryArray {
                            let storeFav = StoreFavorite.init(dictionary: storeFavDictionary)
                            favOnlyArray.append(storeFav)
                        }
                        completionHandler(favOnlyArray)
                        return
                    }
                    completionHandler(nil)
                }
            }
        }
    }
    
    
    func updateStoresWithFavorite() -> [Store]? {
        if let storeWithOutFavoriteArray = SharedObjects.shared.stores {
            if let storeFavoriteKeys = SharedObjects.shared.favStores {
                for storeFavoriteKey in storeFavoriteKeys {
                    for storeWithOutFavorite in storeWithOutFavoriteArray {
                        if storeFavoriteKey.storeId == storeWithOutFavorite.storeId {
                            storeWithOutFavorite.isFavorite = storeFavoriteKey.isFavorite
                        }
                    }
                }
                return storeWithOutFavoriteArray
            }
            else {
                return storeWithOutFavoriteArray
            }
        }
        else {
            return nil
        }
    }
    
    func updateProductWithFavorite(productsWithoutFavorite: [Product]?) -> [Product]? {
        if let productWithOutFavoriteArray = productsWithoutFavorite {
            if let productFavoriteKeys = SharedObjects.shared.favProducts {
                for productFavoriteKey in productFavoriteKeys {
                    for productWithOutFavorite in productWithOutFavoriteArray {
                        if productFavoriteKey.productId == productWithOutFavorite.productId {
                            productWithOutFavorite.isFavorite = productFavoriteKey.isFavorite
                        }
                    }
                }
                return productWithOutFavoriteArray
            }
            else {
                return productWithOutFavoriteArray
            }
        }
        else {
            return nil
        }
    }
    
    
    
    func storesWithFilter() -> [Store] {
        var tempStores = [Store]()
        if let stores = SharedObjects.shared.stores, let filterId = categoryId  {
            
            if categoryId == "-1" {
                return stores
            }
            for store in stores {
                let categories = store.categories
                for category in categories {
                    if category.categoryId == filterId {
                        tempStores.append(store)
                        break
                    }
                }
            }
        }
        return tempStores
    }
    
    
    func isStoreFavorited(store: Store) -> Bool {
        let stores = self.favStores?.filter{$0.storeId == store.storeId}
        if let stores = stores, let store = stores.first, store.isFavorite == true {
            return true
        }
        else {
            return false
        }
    }
    
    func isProductFavorited(product: Product) -> Bool {
        //print(favProducts?.first?.productId)
        //print(product.productId)
        
        
        if let favProducts = self.favProducts {
            let products = favProducts.filter{$0.productId == product.productId}
            if let product = products.first, product.isFavorite == true {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    func updateIncomingStoresWithFavorite(stores: inout [Store]) -> [Store] {
        for store in stores {
            if let favStores = favStores {
                for favStore in favStores {
                    if store.storeId == favStore.storeId {
                        store.isFavorite = favStore.isFavorite
                    }
                }
            }
            
        }
        return stores
    }
    
    func updateIncomingProductWithFavorite(products: inout [Product]) -> [Product] {
        for product in products {
            if let favProducts = favProducts {
                for favProduct in favProducts {
                    if favProduct.productId == product.productId {
                        product.isFavorite = favProduct.isFavorite
                    }
                }
            }
            
        }
        return products
    }
    
    func updateWithNewOrExistingStoreId(selectedStore: Store) {
        
        if let stores = self.stores {
            let selectedStore = selectedStore

            var dictionary = Dictionary<String, Any>()
            dictionary["storeid"] = selectedStore.storeId
            dictionary["isfavorite"] = !selectedStore.isFavorite // flipping isFavorite
            
            // 1. Create StoreFavorite
            let storeFavorite = StoreFavorite.init(dictionary: dictionary)
            
            // 2. Add it in new favorite or modify existing favorite
            if var favStores = SharedObjects.shared.favStores, favStores.count >= 0 {
                
                if favStores.count == 0 { // no favorite earlier so add it directly
                    favStores.append(storeFavorite)
                    SharedObjects.shared.favStores = favStores
                }
                else { //Check existing and modify it
                    
                    var count = 0
                    for favStore in favStores {
                        if favStore.storeId == storeFavorite.storeId {
                            favStore.isFavorite = storeFavorite.isFavorite
                        }
                        else {
                            count = count + 1
                        }
                    }
                    
                    if count == favStores.count {
                        favStores.append(storeFavorite)
                        SharedObjects.shared.favStores = favStores
                    }
                }
                
            }
            else {
                SharedObjects.shared.favStores = [StoreFavorite]()
                SharedObjects.shared.favStores?.append(storeFavorite)
            }
            
            
            // Update Store
            //print("Before Favorite \(SharedObjects.shared.stores)")
            if let storeFavorites = SharedObjects.shared.favStores {
                for tempStoreFavorite in storeFavorites {
                    for store in stores {
                        if store.storeId == tempStoreFavorite.storeId {
                            store.isFavorite = tempStoreFavorite.isFavorite
                        }
                    }
                    
                }
                //print("After Favorite \(SharedObjects.shared.stores)")
            }
            
            // Update StoreWith Favorties
            SharedObjects.shared.storesWithFavorite = SharedObjects.shared.stores?.filter({ (store) -> Bool in
                return store.isFavorite
            })
            
            Downloader.updateStoreFavorite(store: selectedStore)
        }
    }
    
    func updateWithNewOrExistingProductId(selectedProduct: Product) {
        
        let selectedProduct = selectedProduct
        
        var dictionary = Dictionary<String, Any>()
        dictionary["productid"] = selectedProduct.productId
        dictionary["isfavorite"] = !selectedProduct.isFavorite
        
        // 1. Create ProductFavorite
        let productFavorite = ProductFavorite.init(dictionary: dictionary)
        
        // 2. Add it in new favorite or modify existing favorite
        if var favProducts = SharedObjects.shared.favProducts, favProducts.count >= 0 {
            
            if favProducts.count == 0 { // no favorite earlier so add it directly
                favProducts.append(productFavorite)
                SharedObjects.shared.favProducts = favProducts
            }
            else { //Check existing and modify it
                
                var count = 0
                for favProduct in favProducts {
                    if favProduct.productId == productFavorite.productId {
                        favProduct.isFavorite = productFavorite.isFavorite
                    }
                    else {
                        count = count + 1
                    }
                }
                
                if count == favProducts.count {
                    favProducts.append(productFavorite)
                    SharedObjects.shared.favProducts = favProducts
                }
            }
        }
        else {
            SharedObjects.shared.favProducts = [ProductFavorite]()
            SharedObjects.shared.favProducts?.append(productFavorite)
        }
        
        Downloader.updateProductFavorite(product: selectedProduct)
    }
    
    func clearData() {
        self.favStores = [StoreFavorite]()
        self.storesWithFavorite = [Store]()
        self.favProducts = [ProductFavorite]()
        self.stores = [Store]()
    }
    
}


extension SharedObjects: LocationUpdate {
    func latestCoordinate(_ location: CLLocation) {
        self.location = location
    }
    
    func message(_ string: String) {
        //NotificationCenter.default.post(name: NSNotification., object: <#T##Any?#>)
    }
    
}
