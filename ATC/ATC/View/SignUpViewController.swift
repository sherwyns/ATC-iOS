//
//  SignUpViewController.swift
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

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var HUD:MBProgressHUD!
    
    var operationPayload: OperationPayload?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeViews()
        signupButton.layer.borderColor = UIColor.clear.cgColor
        GIDSignIn.sharedInstance()?.signOut()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //addHUDToView()
        print(operationPayload?.payloadType)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func googleLoginPressed() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func fbLoginPressed() {
        
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"email, first_name, last_name"])?.start(completionHandler: { (requestConnection, result, error) in
                if let error = error {
                    KSToastView.ks_showToast("Please try again")
                }
                else {
                    let result = result as! Dictionary<String, String>
                    if let email = result["email"] as? String, let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let userId = result["id"] as? String {
                        var parameterDictionary = Dictionary<String, Any>()
                        parameterDictionary["email"]         = email
                        parameterDictionary["externalid"]    = userId
                        parameterDictionary["provider"]      = "facebook"
                        parameterDictionary["username"]      = email
                        parameterDictionary["requestCode"]   = 0
                        parameterDictionary["emailVerified"] = false
                        self.showHUD()
                        
                        let urlString = ApiServiceURL.apiInterface(.socialSignUp)
                        
                        Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (facebookResult, errorString) in
                            self.hideHUD()
                            if let error = errorString {
                                KSToastView.ks_showToast(error)
                            }
                            else {
                                
                                if let `facebookResult` = facebookResult {
                                    if let message = facebookResult["message"] as? String, message == "user already exists" {
                                        KSToastView.ks_showToast(message)
                                        return
                                    }
                                }
                                
                                DispatchQueue.main.async(execute: { () -> Void in
                                    ATCUserDefaults.userInfo(mail: email)
                                    ATCUserDefaults.userSignedIn()
                                    SharedObjects.shared.canReloadStore = true
                                    self.updateFavorite()
                                    self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                                    KSToastView.ks_showToast("Welcome!")
                                })
                                print(" result \(facebookResult)")
                            }
                        }
                    }
                }
            })
            return
        }
        
        
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
                        if let email = result["email"] as? String, let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String {
                            var parameterDictionary = Dictionary<String, String>()
                            parameterDictionary["email"] = email
                            parameterDictionary["externalid"]      = "user.userID"
                            parameterDictionary["provider"]      = "facebook"
                            parameterDictionary["username"]      = email
                            parameterDictionary["requestCode"]      = "0"
                            self.showHUD()
                            
                            let urlString = ApiServiceURL.apiInterface(.socialSignUp)
                            
                            Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                                if let error = errorString {
                                    KSToastView.ks_showToast(error)
                                }
                                else {
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        ATCUserDefaults.userInfo(mail: email)
                                        ATCUserDefaults.userSignedIn()
                                        SharedObjects.shared.canReloadStore = true
                                        self.updateFavorite()
                                        self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                                        KSToastView.ks_showToast("Welcome")
                                    })
                                    
                                    print(" result \(parameterDictionary)")
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func signUpPressed() {
        self.view.endEditing(true)
        
        if !emailTextField.isTextEmpty() {
            
            if !passwordTextField.isTextEmpty() {
                
                var parameterDictionary = Dictionary<String, String>()
                parameterDictionary["realm"] = ""
                parameterDictionary["username"] = self.emailTextField.text
                parameterDictionary["email"] = self.emailTextField.text
                parameterDictionary["password"]      = self.passwordTextField.text
                parameterDictionary["emailVerified"]      = "true"


                self.showHUD()
                
                let urlString = ApiServiceURL.apiInterface(.SignUp)
                
                Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                    self.hideHUD()
                    if let error = errorString {
                        KSToastView.ks_showToast(error)
                    }
                    else {
                        print(parameterDictionary)
                        if let result = result, let id = result["id"] as? Int{
                            ATCUserDefaults.userIdentity(id: String(id))
                        }
                        ATCUserDefaults.userInfo(mail: self.emailTextField.text!)
                        ATCUserDefaults.userOpenedApp()
                        ATCUserDefaults.userSignedIn()
                        SharedObjects.shared.canReloadStore = true
                        self.updateFavorite()
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                            KSToastView.ks_showToast("Welcome!")
                        })
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
        self.hideHUD()
    }

}

extension SignUpViewController {
    // MARK: - HUD
    func addHUDToView() {
        HUD = MBProgressHUD(view: self.view)
        self.view.addSubview(HUD)
        HUD.frame.origin = CGPoint(x: self.view.frame.origin.x/2, y: self.view.frame.origin.y/2)
        HUD.frame.size  = CGSize(width: 50, height: 50)
        
        HUD.mode = MBProgressHUDMode.indeterminate
        HUD.isUserInteractionEnabled = true
    }
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

extension SignUpViewController {
    func customizeViews() {
        passwordTextField.makeRoundedCorner()
        emailTextField.makeRoundedCorner()
        facebookButton.makeRoundedCorner()
        googleButton.makeRoundedCorner()
        signupButton.makeRoundedCorner()
        signupButton.applyGradient(withColours: [.lightOrange(), .darkOrange()], gradientOrientation: .horizontal)
        view.applyGradient(withColours: [.lightBlue(), .darkBlue()], gradientOrientation: .vertical)
    }
}

extension SignUpViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SignUpViewController: GIDSignInUIDelegate {
    
}


extension SignUpViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            
        }else {
            print(user.profile.email)
            
            var parameterDictionary = Dictionary<String, Any>()
            parameterDictionary["email"] = user.profile.email!
            parameterDictionary["externalid"]      = user.userID
            parameterDictionary["provider"]      = "google"
            parameterDictionary["username"]      = user.profile.email!
            parameterDictionary["requestCode"]      = 0
            self.showHUD()
            
            let urlString = ApiServiceURL.apiInterface(.socialSignUp)
            
            Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (googleResult, errorString) in
                self.hideHUD()
                if let error = errorString {
                    KSToastView.ks_showToast(error)
                }
                else {
                    if let `googleResult` = googleResult {
                        if let message = googleResult["message"] as? String, message == "user already exists" {
                            KSToastView.ks_showToast(message)
                            return
                        }
                        if let userId = googleResult["userId"] as? Int {
                            DispatchQueue.main.async(execute: { () -> Void in
                                ATCUserDefaults.userOpenedApp()
                                ATCUserDefaults.userSignedIn()
                                SharedObjects.shared.canReloadStore = true
                                self.updateFavorite()
                                ATCUserDefaults.userIdentity(id: String(userId))
                                ATCUserDefaults.userInfo(mail:user.profile.email!)
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

extension SignUpViewController: FavoriteProtocol {
    
}

extension UIViewController {
    func updateFavorite() {
        if let favProtocol = self as? FavoriteProtocol {
            if let favoritePayloadType = favProtocol.operationPayload?.payloadType {
                switch favoritePayloadType {
                case .Favorite:
                    if let store = favProtocol.operationPayload?.payloadData as? Store {
                        SharedObjects.shared.updateWithNewOrExistingStoreId(selectedStore: store)
                    }
                    else if let product = favProtocol.operationPayload?.payloadData as? Product {
                        SharedObjects.shared.updateWithNewOrExistingProductId(selectedProduct: product)
                    }
                }
            }
        }
    }
}

//{
//    "email": "testme@enqos.com",
//    "externalid": "test@123",
//    "provider":"facebook"
//}
