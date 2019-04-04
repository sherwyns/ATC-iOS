//
//  AccountViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 05/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit
import MBProgressHUD
import KSToastView

class AccountViewController: UIViewController {
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var expand: UIButton!
    @IBOutlet weak var signOut: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var changePasswordStackView: UIStackView!
    @IBOutlet var HUD:MBProgressHUD!
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let userName = ATCUserDefaults.userInfo() {
            self.userLabel.text = userName
        }
        else {
            self.userLabel.text = "XXXXX XXXXX"
        }
        expand.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        updateImageForExpandButton()
    }
    
    func customizeViews() {
        newPasswordTextField.makeRoundedCorner()
        oldPasswordTextField.makeRoundedCorner()
        confirmPasswordTextField.makeRoundedCorner()
        signOut.makeRoundedCorner()
        changePasswordButton.makeRoundedCorner()
        signOut.applyGradient(withColours: [.lightOrange(), .darkOrange()], gradientOrientation: .horizontal)
    }
    
    override func backAction() {
        self.navigationController?.dismiss(animated: true, completion: { })
    }
    
    fileprivate func updateImageForExpandButton() {
        if changePasswordStackView.isHidden {
            expand.setImage(UIImage.init(named: "downArrow"), for: .normal)
        }
        else {
            expand.setImage(UIImage.init(named: "upArrow"), for: .normal)
        }
    }
    
    @IBAction func showOrHideChangePassword() {
        changePasswordStackView.isHidden = !changePasswordStackView.isHidden
        updateImageForExpandButton()
    }
    
    @IBAction func signoutAction() {
        ATCUserDefaults.logoutApp()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        SharedObjects.shared.canReloadStore = true
        if let tabbar = appDelegate.tabbarController {
            for controller in tabbar.viewControllers! {
                if let vc = controller as? EntityProtocol {
                    vc.entityViewController?.stores = [Store]()
                    vc.entityViewController?.collectionView.reloadData()
                }
            }
        }
        self.dismiss(animated: true) {}
    }
    
    @IBAction func changePasswordAction() {
        self.view.endEditing(true)
        
        guard let token = ATCUserDefaults.changePasswordToken() else {
            KSToastView.ks_showToast("Please try again") // no token available
            self.hideHUD()
            return
        }
        
        if !oldPasswordTextField.isTextEmpty() {
            
            if !newPasswordTextField.isTextEmpty() {
                
                if !confirmPasswordTextField.isTextEmpty() {
                    
                    
                    if let newPassword = newPasswordTextField.text, let oldPassword = oldPasswordTextField.text, newPassword == oldPassword {
                        KSToastView.ks_showToast("Old and new password are same")
                        return
                    }
                    if let newPassword = newPasswordTextField.text, let confirmPassword = confirmPasswordTextField.text, newPassword != confirmPassword {
                        KSToastView.ks_showToast("New and confirm password doesn't match")
                        return
                    }
                    
                    var parameterDictionary = Dictionary<String, String>()
                    parameterDictionary["oldPassword"] = self.oldPasswordTextField.text!
                    parameterDictionary["newPassword"] = self.newPasswordTextField.text!
                    
                    self.showHUD()
                    
                    let urlString = "\(ApiServiceURL.apiInterface(.changePassword))?access_token=\(token)"
                    
                    Downloader.getJSONUsingURLSessionPOSTRequest(url: urlString, parameters: parameterDictionary) { (changePasswordResult, errorString) in
                        self.hideHUD()
                        if let error = errorString {
                            KSToastView.ks_showToast(error)
                            return
                        }
                        else {
                            if let changePasswordResult = changePasswordResult, let message = changePasswordResult["resultMessage"] as? String, message == "Success"{
                                KSToastView.ks_showToast("Password updated successfully!!!")
                                
                                DispatchQueue.main.async {
                                    self.oldPasswordTextField.text = ""
                                    self.newPasswordTextField.text = ""
                                    self.confirmPasswordTextField.text = ""
                                    self.showOrHideChangePassword()
                                    self.backAction()
                                }
                                return
                            }
                        }
                    }
                    
                }
                else {
                    KSToastView.ks_showToast("Enter confirm password!")
                }
            }
            else {
                KSToastView.ks_showToast("Enter  new password!")
            }
        }
        else {
            KSToastView.ks_showToast("Enter  old Password!")
        }
        return
    }
}

extension AccountViewController {
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
