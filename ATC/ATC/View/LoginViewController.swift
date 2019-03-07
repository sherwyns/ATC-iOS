//
//  LoginViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 22/10/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import MBProgressHUD
import KSToastView
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
     @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: GIDSignInButton!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var HUD:MBProgressHUD!
    
    var operationPayload: OperationPayload?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        loginButton.layer.borderColor = UIColor.clear.cgColor
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func loginAction() {
        self.view.endEditing(true)

        if !emailTextField.isTextEmpty() {
            
            if !passwordTextField.isTextEmpty() {
               
                var parameterDictionary = Dictionary<String, String>()
                parameterDictionary["username"] = self.emailTextField.text
                parameterDictionary["password"]      = self.passwordTextField.text
                
                self.showHUD()
                
                let urlString = ApiServiceURL.apiInterface(.Login)
                
                Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (loginResult, errorString) in
                    self.hideHUD()
                    if let error = errorString {
                        self.hideHUD()
                        KSToastView.ks_showToast(error)
                    }
                    else {
                        print(parameterDictionary)
                        if let error = parameterDictionary["error"] as? Dictionary<String, AnyObject?> {
                            if let message = error["message"] as? String {
                                KSToastView.ks_showToast(message)
                            }
                        }
                        else {
                            if let `loginResult` = loginResult {
                                if let message = loginResult["message"] as? String, message == "user already exists" {
                                    KSToastView.ks_showToast(message)
                                    return
                                }
                                if let userId = loginResult["userId"] as? Int, let token = loginResult["id"] as? String {
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        ATCUserDefaults.userOpenedApp()
                                        ATCUserDefaults.userSignedIn()
                                        SharedObjects.shared.canReloadStore = true
                                        self.updateFavorite()
                                        ATCUserDefaults.userIdentity(id: String(userId))
                                        ATCUserDefaults.userInfo(mail:self.emailTextField.text!)
                                        ATCUserDefaults.changePasswordToken(token)
                                        Downloader.retrieveStoreFavorites()
                                        Downloader.retrieveProductFavorites()
                                        self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                                    })
                                    KSToastView.ks_showToast("Welcome!")
                                }
                            }
                            else {
                                KSToastView.ks_showToast("Please try Again")
                            }
                        }
                    }
                }
                
            }
            else {
                KSToastView.ks_showToast("Enter Password!")
            }
        }
        else {
            KSToastView.ks_showToast("Enter  User Name!")
        }
        
        return
    }
    
    @IBAction func googleLoginPressed() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func fbLoginPressed() {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            print(error)
            print(result)
            if let error = error {
                KSToastView.ks_showToast("Please try again")
            }
            else {
                FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"email, first_name, last_name"])?.start(completionHandler: { (requestConnection, result, error) in
                    if let error = error {
                        KSToastView.ks_showToast("Please try again")
                    }
                    else {
                        let result = result as! Dictionary<String, String>
                        if let email = result["email"] as? String, let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let userId = result["id"] as? String {
                            var parameterDictionary = Dictionary<String, Any>()
                            parameterDictionary["email"]       = email
                            parameterDictionary["externalid"]  = userId
                            parameterDictionary["provider"]    = "facebook"
                            parameterDictionary["requestCode"] = 0
                            self.showHUD()
                            
                            let urlString = ApiServiceURL.apiInterface(.socialSignIn)
                            
                            Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (facebookResult, errorString) in
                                self.hideHUD()
                                if let _ = errorString {
                                    KSToastView.ks_showToast("Please try again")
                                }
                                else {
                                    if let facebookResult = facebookResult {
                                        if let userId = facebookResult["userId"] as? Int, let token = facebookResult["id"] as? String {
                                            DispatchQueue.main.async(execute: { () -> Void in
                                                ATCUserDefaults.userOpenedApp()
                                                ATCUserDefaults.userSignedIn()
                                                SharedObjects.shared.canReloadStore = true
                                                self.updateFavorite()
                                                ATCUserDefaults.userIdentity(id: String(userId))
                                                ATCUserDefaults.userInfo(mail:email)
                                                ATCUserDefaults.changePasswordToken(token)
                                                Downloader.retrieveStoreFavorites()
                                                Downloader.retrieveProductFavorites()
                                                self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                                            })
                                            KSToastView.ks_showToast("Welcome!")
                                        }
                                    }
                                    else {
                                        KSToastView.ks_showToast("Please try Again")
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
}

extension LoginViewController {
    // MARK: - HUD
    
    func showHUD(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.HUD.show(animated: true)
        })
    }
    
    func hideHUD(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.HUD.hide(animated: true)
        })
    }
}

extension LoginViewController {
    func customizeViews() {
        passwordTextField.makeRoundedCorner()
        emailTextField.makeRoundedCorner()
        facebookButton.makeRoundedCorner()
        googleButton.makeRoundedCorner()
        loginButton.makeRoundedCorner()
        forgotButton.contentHorizontalAlignment = .right
        loginButton.applyGradient(withColours: [.lightOrange(), .darkOrange()], gradientOrientation: .horizontal)
        view.applyGradient(withColours: [.lightBlue(), .darkBlue()], gradientOrientation: .vertical)
    }
}

extension LoginViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIView {
    func makeRoundedCorner() {
        self.layer.cornerRadius = 30.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
    }
}

extension LoginViewController: GIDSignInUIDelegate {
    
}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            
        }else {
            print(user.profile.email)
            
            var parameterDictionary = Dictionary<String, Any>()
            parameterDictionary["email"] = user.profile.email!
            parameterDictionary["externalid"]      = user.userID
            parameterDictionary["provider"]      = "google"
            parameterDictionary["requestCode"]      = 0
            self.showHUD()
            
            let urlString = ApiServiceURL.apiInterface(.socialSignIn)
            
            Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (googleResult, errorString) in
                self.hideHUD()
                if let error = errorString {
                    KSToastView.ks_showToast(error)
                }
                else {
                    if let `googleResult` = googleResult {
                        if let userId = googleResult["userId"] as? Int,  let token = googleResult["id"] as? String  {
                            DispatchQueue.main.async(execute: { () -> Void in
                                ATCUserDefaults.userOpenedApp()
                                ATCUserDefaults.userSignedIn()
                                SharedObjects.shared.canReloadStore = true
                                self.updateFavorite()
                                ATCUserDefaults.userIdentity(id: String(userId))
                                ATCUserDefaults.userInfo(mail:user.profile.email!)
                                ATCUserDefaults.changePasswordToken(token)
                                Downloader.retrieveStoreFavorites()
                                Downloader.retrieveProductFavorites()
                                self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                            })
                            KSToastView.ks_showToast("Welcome!")
                        }
                    }
                    else {
                        KSToastView.ks_showToast("Please try Again")
                    }
                }
            }
        }
    }
}
