//
//  WatchSession.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 4/13/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import WatchKit
import WatchConnectivity

class WatchSession: NSObject, WCSessionDelegate {
    
    //MARK: Session Functions
    
    //This function is called when the watch session completes activation
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session started")
    }
    
    //MARK: Variables
    
    static let sharedInstance = WatchSession()
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
    
    //MARK: Data Senders
    
    //This function sends a message to PhoneSession with the key tellPhoneToBeTheController
    func getMoviesFromPhone() {
        print("Sending message")
        let actionDictFromWatch = ["Action": "getMoviesFromPhone"]
        session.sendMessage(actionDictFromWatch, replyHandler: nil)
    }
    
    func tellPhoneToStopGame() {
        //self.startSession()
        print("tellphonetostopgame")
        let actionDictFromWatch = ["Action": "tellPhoneToBeController"]
        session.sendMessage(actionDictFromWatch, replyHandler: nil)
    }

    
    //MARK: Data Getters
    
    //This functions receives a message from the Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: message["Action"]! as! String), object: message["Payload"])
        }
    }

}
