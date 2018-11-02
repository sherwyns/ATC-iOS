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
                    KSToastView.ks_showToast(error.localizedDescription)
                }
                else {
                    let result = result as! Dictionary<String, String>
                    if let email = result["email"] as? String, let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String {
                        var parameterDictionary = Dictionary<String, String>()
                        parameterDictionary["email"] = email
                        parameterDictionary["externalid"]      = "user.userID"
                        parameterDictionary["provider"]      = "facebook"
                        self.showHUD()
                        
                        let urlString = ApiServiceURL.apiInterface(.socialSignUp)
                        
                        Downloader.getJSONUsingURLSession(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                            if let error = errorString {
                                KSToastView.ks_showToast(error)
                            }
                            else {
                                DispatchQueue.main.async(execute: { () -> Void in
                                    self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                                    KSToastView.ks_showToast("Welcome!")
                                })
                                
                                print(" result \(parameterDictionary)")
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
                KSToastView.ks_showToast(error.localizedDescription)
            }
            else {
                FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"email, first_name, last_name"])?.start(completionHandler: { (requestConnection, result, error) in
                    if let error = error {
                        KSToastView.ks_showToast(error.localizedDescription)
                    }
                    else {
                        let result = result as! Dictionary<String, String>
                        if let email = result["email"] as? String, let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String {
                            var parameterDictionary = Dictionary<String, String>()
                            parameterDictionary["email"] = email
                            parameterDictionary["externalid"]      = "user.userID"
                            parameterDictionary["provider"]      = "facebook"
                            self.showHUD()
                            
                            let urlString = ApiServiceURL.apiInterface(.socialSignUp)
                            
                            Downloader.getJSONUsingURLSession(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                                if let error = errorString {
                                    KSToastView.ks_showToast(error)
                                }
                                else {
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
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
                
                Downloader.getJSONUsingURLSession(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                    if let error = errorString {
                        KSToastView.ks_showToast(error)
                    }
                    else {
                        print(parameterDictionary)
                        ATCUserDefaults.userOpenedApp()
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
            
            var parameterDictionary = Dictionary<String, String>()
            parameterDictionary["email"] = user.profile.email!
            parameterDictionary["externalid"]      = user.userID
            parameterDictionary["provider"]      = "google"
            self.showHUD()
            
            let urlString = ApiServiceURL.apiInterface(.socialSignUp)
            
            Downloader.getJSONUsingURLSession(url: urlString, parameters: parameterDictionary) { (result, errorString) in
                if let error = errorString {
                    KSToastView.ks_showToast(error)
                }
                else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.performSegue(withIdentifier: "startShoppingSegue", sender: nil)
                    })
                    KSToastView.ks_showToast("Welcome!")
                    print(" result \(parameterDictionary)")
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
