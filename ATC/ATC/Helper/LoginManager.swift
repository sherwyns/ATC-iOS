//
//  LoginManager.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 29/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import Foundation
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
class LoginManager {
    static func logout(){
        GIDSignIn.sharedInstance()?.signOut()
//        FBSession.activeSession.closeAndClearTokenInformation()
        SharedObjects.shared.canReloadStore = true
        FBSDKLoginManager().logOut()
    }
}
