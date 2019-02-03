//
//  Constants.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation

enum APIMethod: String {
    case Login             = "Users/login"
    case SignUp            = "Users"
    case socialSignIn      = "socialUsers/signin"
    case socialSignUp      = "socialUsers/signup"
    case getStores         = "Store/getstores/"
    case getProductByStore = "products/getproductbystore/"
    case getCategoriesList = "categories/list"
    case search            = "search/by/"
    case products          = "products"
    case storeDetail       = "store/"
    case getFavoriteList   = "favorite/list"
    case saveFavorite      = "favorite/save"
}

class ApiServiceURL {
    static let scheme     = "https://"
//    static let domain     = "dev.aroundthecorner.store/"
    static let domain     = "api.aroundthecorner.store/"  // Live
    static let apiVersion = "api/"
    
    static func apiInterface(_ apiMethod : APIMethod) -> String{
        return scheme + domain + apiVersion + apiMethod.rawValue
    }
}

public class NotificationConstant {
    static let showRegistration = NSNotification.Name(rawValue: "ShowRegistration")
    static let showMyAccount = NSNotification.Name(rawValue: "showMyAccount")
}
