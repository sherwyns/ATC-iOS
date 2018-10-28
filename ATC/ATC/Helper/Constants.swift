//
//  Constants.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation

enum APIMethod: String {
    case Login                   = "Users/login"
    case SignUp    = "Users"
    case socialSignUp = "socialUsers/signin"
}

class ApiServiceURL {
    static let scheme     = "http://"
    static let domain     = "34.209.125.112/"    // Live
    static let apiVersion = "api/"
    
    static func apiInterface(_ apiMethod : APIMethod) -> String{
        return scheme + domain + apiVersion + apiMethod.rawValue
    }
}
