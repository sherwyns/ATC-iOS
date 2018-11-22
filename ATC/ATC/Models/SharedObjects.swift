//
//  SharedObjects.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 20/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation

class SharedObjects{
    
    static let shared = SharedObjects()
    
    var stores: [Store]?
    
    var storesForFavorite: [Store]?
    
    var favStores: [StoreFavorite]? // will contain only favorite items
    
    
    
    private init(){}
    
    func getStoresWithFavorite(completionHandler: @escaping ([Store]?) -> Void) {
        var storeWithOutFavoriteArray = [Store]()
        var storeWithFavoriteArray = [Store]()
        let storeUrlString = ApiServiceURL.apiInterface(.getStores)
        Downloader.getStoreJSONUsingURLSession(url: storeUrlString) { (result, errorString) in
            if let error = errorString {
                completionHandler(nil)
            }
            else {
                print(result)
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
            print(url)   // "https://www.google.com/search?q=Formula%20One"
            
            Downloader.getStoreJSONUsingURLSession(serviceUrl: url) { (result, errorString) in
                if let error = errorString {
                    completionHandler(nil)
                }
                else {
                    print(result)
                    
                    if let result = result, let storeFavDictionaryArray = result["store"] as? Array<Dictionary<String, Any>> {
                        print(storeFavDictionaryArray)
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
                var favoriteArray = [Store]()
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
    
    
    func updateWithNewOrExistingStoreId(selectedStore: Store) {
        
        if let stores = self.stores {
            let selectedStore = selectedStore

            var dictionary = Dictionary<String, Any>()
            dictionary["storeid"] = selectedStore.storeId
            dictionary["isfavorite"] = !selectedStore.isFavorite
            
            // 1. Create StoreFavorite
            var storeFavorite = StoreFavorite.init(dictionary: dictionary)
            
            // 2. Add it in new favorite or modify existing favorite
            if var favStores = SharedObjects.shared.favStores, favStores.count >= 0 {
                
                if favStores.count == 0 { // no favorite earlier add
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
            print("Before Favorite \(SharedObjects.shared.stores)")
            if let storeFavorites = SharedObjects.shared.favStores {
                for tempStoreFavorite in storeFavorites {
                    for store in stores {
                        if store.storeId == tempStoreFavorite.storeId {
                            store.isFavorite = tempStoreFavorite.isFavorite
                        }
                    }
                    
                }
                
                print("After Favorite \(SharedObjects.shared.stores)")
                
            }
            
            // Update StoreWith Favorties
            
            SharedObjects.shared.storesForFavorite = SharedObjects.shared.stores?.filter({ (store) -> Bool in
                return store.isFavorite
            })
            
            print(storesForFavorite?.count)
        }
    }
    
    func clearData() {
        self.favStores = [StoreFavorite]()
        self.storesForFavorite = [Store]()
        self.stores = [Store]()
    }
    
}
