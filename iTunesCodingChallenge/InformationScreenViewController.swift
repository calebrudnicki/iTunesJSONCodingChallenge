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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //This function sets the segmented controller to the correct selected index
    override func viewDidLoad() {
        super.viewDidLoad()
        if appDelegate.isSeeingRentalPrice == false {
            priceSegmentedControl.selectedSegmentIndex = 0
        } else {
            priceSegmentedControl.selectedSegmentIndex = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //This function makes the status bar white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //THis functions changes the app wide price value when the segmented controller is changed
    @IBAction func priceSegmentedControlHasChanged(_ sender: Any) {
        print("Changed")
        if priceSegmentedControl.selectedSegmentIndex == 0 {
            appDelegate.isSeeingRentalPrice = false
        } else {
            appDelegate.isSeeingRentalPrice = true
        }
    }

    //This function take the user back into the app when the back to app button is tapped
    @IBAction func backToAppButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
