//
//  OnboardingViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 4/4/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This function makes the status bar white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //This function continues to the home page of the app once the user has read the tutorial
    @IBAction func gotItButtonTapped(_ sender: Any) {
        //The type of segue used depends on whether or not this is a first time user
        if (UserDefaults.standard.value(forKey: "name") as? String) == nil {
            UserDefaults.standard.set("User", forKey: "name")
            performSegue(withIdentifier: "showMainPageSegue", sender: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
