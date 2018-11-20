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
    
    var favStores: [Store]? // will contain only favorite items
    
    
    
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
                                        storeWithOutFavorite.isFavorite = storeFavoriteKey.isFavorite
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
    
    
    
}
