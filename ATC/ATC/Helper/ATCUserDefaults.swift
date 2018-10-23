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
    
    static func userOpenedApp() {
        UserDefaults.standard.setValue(false, forKey: kIsFirstTime)
        UserDefaults.standard.synchronize()
    }
}
