//
//  User.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 7/7/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import FirebaseAuth

class AppUser {
    let uid: String
    let email: String
    
    init(userData: User) {
        uid = userData.uid
        if let mail = userData.providerData.first?.email {
            email = mail
        } else {
            email = ""
        }
    }

    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
