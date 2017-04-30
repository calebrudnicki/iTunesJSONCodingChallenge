//
//  InformationScreenViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 4/10/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit

class InformationScreenViewController: UIViewController {

    @IBOutlet weak var priceSegmentedControl: UISegmentedControl!
        
    //This function sets the segmented controller to the correct selected index
    override func viewDidLoad() {
        super.viewDidLoad()
        if let priceDefault = UserDefaults.standard.object(forKey: "isSeeingRentalPrice") as? Bool {
            if priceDefault == false {
                priceSegmentedControl.selectedSegmentIndex = 0
            } else {
                priceSegmentedControl.selectedSegmentIndex = 1
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //This function makes the status bar white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //This functions changes the app wide price value when the segmented controller is changed
    @IBAction func priceSegmentedControllerHasChanged(_ sender: Any) {
        if priceSegmentedControl.selectedSegmentIndex == 0 {
            UserDefaults.standard.set(false, forKey: "isSeeingRentalPrice")
        } else {
            UserDefaults.standard.set(true, forKey: "isSeeingRentalPrice")
        }
    }

    //This function take the user back into the app when the back to app button is tapped
    @IBAction func backToAppButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
