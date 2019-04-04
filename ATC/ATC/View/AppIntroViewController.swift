//
//  AppIntroViewController.swift
//  ATC
//
//  Created by Rathinavel, Dhandapani on 01/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class AppIntroViewController: UIViewController {
    //segueToEmbed
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier, segueIdentifier == "segueToEmbed" {
            if let destinationVC = segue.destination as? ATCPageViewController {
                destinationVC.appIntroViewController = self
            }
        }
    }
    
    @IBAction func dismissAppWalkthrough() {
        ATCUserDefaults.appWalkthroughDone()
        self.dismiss(animated: true, completion: nil)
    }
}
