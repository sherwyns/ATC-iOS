//
//  SearchViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 04/11/18.
//  Copyright © 2018 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
  
  
  @IBAction func logoutAction() {
    LoginManager.logout()
    
    if let parent = self.parent as? ATCTabBarViewController {
      parent.showRegistration()
    }
  }

}

extension UIViewController {
    @IBAction func openSettings() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.slideMenuController.openRight()
    }
}
