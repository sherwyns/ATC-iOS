//
//  ATCUserDefaults.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 21/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import UIKit

public class ATCUserDefaults {
    static let kIsFirstTime    = "isFirstTime"
    static let kIsUserLoggedIn = "isUserLoggedIn"
    static let kUserInfo       = "userInfo"
    static let kUserId       = "userId"
    
    static func isUserLoggedIn() -> Bool {
        if let isUserLoggedIn = UserDefaults.standard.value(forKey: kIsUserLoggedIn) as? Bool {
            return isUserLoggedIn
        }
        return false
    }
    
    static func isFirstTime() -> Bool {
        if let isFirstTime = UserDefaults.standard.value(forKey: kIsFirstTime) as? Bool {
            return isFirstTime
        }
        return true
    }
    
    static func userInfo() -> String? {
        if let userMail = UserDefaults.standard.value(forKey: kUserInfo) as? String {
            return userMail
        }
        return nil
    }
    
    static func userId() -> String? {
        if let userId = UserDefaults.standard.value(forKey: kUserId) as? String {
            return userId
        }
        return nil
    }
    
    static func userOpenedApp() {
        UserDefaults.standard.setValue(false, forKey: kIsFirstTime)
        UserDefaults.standard.synchronize()
    }
    
    static func userSignedIn() {
        UserDefaults.standard.setValue(true, forKey: kIsUserLoggedIn)
        UserDefaults.standard.synchronize()
    }
    
    static func logoutApp() {
        SharedObjects.shared.clearData()
        UserDefaults.standard.setValue(false, forKey: kIsUserLoggedIn)
        UserDefaults.standard.synchronize()
    }

    static func userInfo(mail : String) {
        UserDefaults.standard.setValue(mail, forKey: kUserInfo)
        UserDefaults.standard.synchronize()
    }
    
    static func userIdentity(id : String) {
        UserDefaults.standard.setValue(id, forKey: kUserId)
        UserDefaults.standard.synchronize()
    }
}
