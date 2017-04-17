//
//  PhoneSession.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 4/13/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import WatchConnectivity

class PhoneSession: NSObject, WCSessionDelegate {
    
    //MARK: Session Functions
    
    //This function is called when the phone session completes activation
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Phone session activation complete")
    }
    //This function is called when the phone session did become inactive
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("Phone session did become inactive")
    }
    //This function is called when the phone session did deactivate
    public func sessionDidDeactivate(_ session: WCSession) {
        print("Phone session did deactivate")
    }
    
    //MARK: Variables
    
    static let sharedInstance = PhoneSession()
    var session: WCSession!
    
    //MARK: Session Creation
    
    //This function creates a session
    func startSession() {
        if WCSession.isSupported() {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }
    
    //MARK: Data Getters
    
    //This functions receives a message from the Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("Phone getting notification")
            NotificationCenter.default.post(name: Notification.Name(rawValue: message["Action"]! as! String), object: message["Payload"])
        }
    }

}
