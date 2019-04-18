//
//  ComingSoonViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 08/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class ComingSoonViewController: UIViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        let height = (self.view.frame.size.width * 0.35) * 0.40
        let rightConstriant = (self.view.frame.size.width * 0.35) * 0.25
        
        self.topConstraint.constant = self.view.frame.size.height * 0.69
        self.leftConstraint.constant = self.view.frame.size.width * 0.1576
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
