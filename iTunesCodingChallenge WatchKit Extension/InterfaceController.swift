//
//  InterfaceController.swift
//  iTunesCodingChallenge WatchKit Extension
//
//  Created by Caleb Rudnicki on 4/13/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    var list = ["Caleb", "Sarah", "Jared", "Samantha", "Momlipi", "Philipé"]

    //This function calls loadTable()
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        WatchSession.sharedInstance.startSession()
        self.loadTable()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    //This function loads the table view with some dummy data
    func loadTable() {
        tableView.setNumberOfRows(list.count, withRowType: "rowController")
        var i = 0
        for l in list {
            let row = tableView.rowController(at: i) as! InterfaceControllerTableViewCell
            row.rowLabel.setText(l)
            i += 1
        }
    }
    
    @IBAction func buttonTapped() {
        WatchSession.sharedInstance.tellPhoneToStopGame()
    }

}
