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

    @IBAction func skipButtonTapped(_ sender: Any) {
        UserDefaults.standard.set("User", forKey: "name")
        performSegue(withIdentifier: "showMainPageSegue", sender: nil)
    }
}
