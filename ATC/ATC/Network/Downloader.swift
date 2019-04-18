//
//  Downloader.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import AFNetworking

class Downloader {
    static let UUID_HEADER = "X-Header-UUID"
    
static func getJSONUsingURLSessionPOSTRequest(url : String, parameters : Dictionary<String, Any>,  completionHandler: @escaping (_ result : Dictionary<String, AnyObject?>?, _ error: String?) -> Void) {
        
        guard let serviceUrl = URL(string: url) else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(uniqueDeviceIdentifier(), forHTTPHeaderField: UUID_HEADER)
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let emptyString = String.init(data: data, encoding: String.Encoding.ascii), emptyString.count == 0 {
                    var dictionary = Dictionary<String, AnyObject>()
                    dictionary["resultMessage"] = "Success" as AnyObject
                    completionHandler(dictionary, nil)
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? Dictionary<String, AnyObject?>
                    //print(json!)
                    if let json = json {
                        if let error = json["error"] as? Dictionary<String, AnyObject>, let message = error["message"]  as? String {
                            completionHandler(nil, message)
                        }
                        else {
                            completionHandler(json, nil)
                        }
                    }
                }catch {
                    //print(error)
                    completionHandler(nil, "Please try again")
                }
            }
        }.resume()
    }
    
    static func getStoreJSONUsingURLSession(url : String, completionHandler: @escaping (_ result : Dictionary<String, AnyObject?>?, _ error: String?) -> Void) {
        
        guard let serviceUrl = URL(string: url) else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue(uniqueDeviceIdentifier(), forHTTPHeaderField: UUID_HEADER)
        let taskDelegate = TaskDelegate()
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? Dictionary<String, AnyObject?>
                    //print(json!)
                    if let json = json {
                        if let error = json["error"] as? Dictionary<String, AnyObject>, let message = error["message"]  as? String {
                            completionHandler(nil, message)
                        }
                        else {
                            completionHandler(json, nil)
                        }
                    }
                }catch {
                    //print(error)
                    completionHandler(nil, "Please try again")
                }
            }
            else {
                completionHandler(nil, "Please try again")
            }
        }.resume()
    }
    
    static func getAnyJSONUsingURLSession(url : String, completionHandler: @escaping (_ result :Any?, _ error: String?) -> Void) {
    
        guard let serviceUrl = URL(string: url) else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue(uniqueDeviceIdentifier(), forHTTPHeaderField: UUID_HEADER)
        let taskDelegate = TaskDelegate()
        
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? Array<Dictionary<String, AnyObject?>>
                    //print(json!)
                    if let json = json {
                         completionHandler(json, nil)
                    }
                }catch {
                    //print(error)
                    completionHandler(nil, "Please try again")
                }
            }
            else {
                completionHandler(nil, "Please try again")
            }
            }.resume()
    }
    
    static func getStoreJSONUsingURLSession(serviceUrl : URL, completionHandler: @escaping (_ result : Dictionary<String, AnyObject?>?, _ error: String?) -> Void) {
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue(uniqueDeviceIdentifier(), forHTTPHeaderField: UUID_HEADER)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? Dictionary<String, AnyObject?>
                    //print(json!)
                    if let json = json {
                        if let error = json["error"] as? Dictionary<String, AnyObject>, let message = error["message"]  as? String {
                            completionHandler(nil, message)
                        }
                        else {
                            completionHandler(json, nil)
                        }
                    }
                }catch {
                    //print(error)
                    completionHandler(nil, "Please try again")
                }
            }
            else {
                completionHandler(nil, "Please try again")
            }
            }.resume()
    }
    
    static func retrieveCategories() {
        let urlString = ApiServiceURL.apiInterface(APIMethod.getCategoriesList)
        
        Downloader.getStoreJSONUsingURLSession(url: urlString) { (result, errorString) in
            if let _ = errorString {
                
            }
            else {
                if let result = result, let categoryDictionaryArray = result["data"] as? Array<Dictionary<String, Any>> {
                    var categories = [Category]()
                    for categoryDictionary in categoryDictionaryArray {
                        let category = Category.init(dictionary: categoryDictionary)
                        categories.append(category)
                    }
                    SharedObjects.shared.categories = categories
                }
            }
        }
    }
    
    static func updateStoreFavorite(store: Store) {
        
        guard let userId = ATCUserDefaults.userId(), let intUserId = Int(userId) else {
            return
        }
        
        var parameterDictionary = Dictionary<String, Any>()
        parameterDictionary["user_id"]    = intUserId
        parameterDictionary["id"]         = store.storeId
        parameterDictionary["isfavorite"] = store.isFavorite
        parameterDictionary["type"]       = "store"
        Downloader.getJSONUsingURLSessionPOSTRequest(url: ApiServiceURL.apiInterface(.saveFavorite), parameters: parameterDictionary) { (resultDictionary, error) in
            //print(resultDictionary!)
        }
    }
    
    static func updateProductFavorite(product: Product) {
        
        guard let userId = ATCUserDefaults.userId(), let intUserId = Int(userId) else {
            return
        }
        
        var parameterDictionary = Dictionary<String, Any>()
        parameterDictionary["user_id"]    = intUserId
        parameterDictionary["id"]         = product.productId
        parameterDictionary["isfavorite"] = !product.isFavorite
        parameterDictionary["type"]       = "product"
        Downloader.getJSONUsingURLSessionPOSTRequest(url: ApiServiceURL.apiInterface(.saveFavorite), parameters: parameterDictionary) { (resultDictionary, error) in
            //print(resultDictionary!)
        }
    }
    
    static func uniqueDeviceIdentifier() -> String{
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
        }
        return String()
    }
    
    static func retrieveStoreFavorites() {
        guard let userId = ATCUserDefaults.userId(), let intUserId = Int(userId) else {
            return
        }
        var parameterDictionary = Dictionary<String, Any>()
        parameterDictionary["user_id"]    = intUserId
        parameterDictionary["type"]       = "store"
        
        Downloader.getJSONUsingURLSessionPOSTRequest(url: ApiServiceURL.apiInterface(.getFavoriteList), parameters: parameterDictionary) { (favStoreList, errorString) in
            if let _ = errorString {
                
            }
            else {
                if let favStoreList = favStoreList, let data = favStoreList["data"] as? Array<Dictionary<String,Any>> {
                    var storeFavorites = [StoreFavorite]()
                    for favorite in data {
                        if let id = favorite["store_id"] as? Int, let isFavorite = favorite["favorite"] as? Bool, isFavorite == true {
                            
                            var dictionary = Dictionary<String, Any>()
                            dictionary["storeid"] = id
                            dictionary["isfavorite"] = true
                            
                            storeFavorites.append(StoreFavorite.init(dictionary: dictionary))
                        }
                    }
                    SharedObjects.shared.favStores = storeFavorites
                }
            }
        }
    }
    
    static func retrieveProductFavorites() {
        guard let userId = ATCUserDefaults.userId(), let intUserId = Int(userId) else {
            return
        }
        var parameterDictionary = Dictionary<String, Any>()
        parameterDictionary["user_id"]    = intUserId
        parameterDictionary["type"]       = "product"
        
        Downloader.getJSONUsingURLSessionPOSTRequest(url: ApiServiceURL.apiInterface(.getFavoriteList), parameters: parameterDictionary) { (favProductList, errorString) in
            if let _ = errorString {
                
            }
            else {
                if let favProductList = favProductList, let data = favProductList["data"] as? Array<Dictionary<String,Any>> {
                    var productFavorites = [ProductFavorite]()
                    for favorite in data {
                        if let id = favorite["product_id"] as? Int, let isFavorite = favorite["favorite"] as? Bool, isFavorite == true {
                            var dictionary = Dictionary<String, Any>()
                            dictionary["productid"] = id
                            dictionary["isfavorite"] = true
                            
                            productFavorites.append(ProductFavorite.init(dictionary: dictionary))
                        }
                    }
                    SharedObjects.shared.favProducts = productFavorites
                }
            }
        }
    }
    
    static func updateJSONUsingURLSessionPOSTRequestForAnalytics(url : String, parameters : Dictionary<String, Any>,  completionHandler: @escaping (_ result : Dictionary<String, AnyObject?>?, _ error: String?) -> Void) {
        
        guard let serviceUrl = URL(string: url) else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(uniqueDeviceIdentifier(), forHTTPHeaderField: UUID_HEADER)
        
        if let token = ATCUserDefaults.changePasswordToken() {
            request.setValue(token, forHTTPHeaderField: "Acces_token")
        }
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                if let emptyString = String.init(data: data, encoding: String.Encoding.ascii), emptyString.count == 0 {
                    var dictionary = Dictionary<String, AnyObject>()
                    dictionary["resultMessage"] = "Success" as AnyObject
                    completionHandler(dictionary, nil)
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? Dictionary<String, AnyObject?>
                    //print(json!)
                    if let json = json {
                        if let error = json["error"] as? Dictionary<String, AnyObject>, let message = error["message"]  as? String {
                            completionHandler(nil, message)
                        }
                        else {
                            completionHandler(json, nil)
                        }
                    }
                }catch {
                    //print(error)
                    completionHandler(nil, "Please try again")
                }
            }
            }.resume()
    }
  
}


class TaskDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
        
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}


