//
//  FirebaseMovie.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 7/7/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Movie {
    
    let name: String?
    let releaseDate: String?
    let purchasePrice: String?
    let rentalPrice: String?
    let summary: String?
    let image: String?
    let rights: String?
    let link: String?
    var rank: Int?
    let key: String!
    let itemRef: DatabaseReference?
    
    init(name: String, releaseDate: String, purchasePrice: String, rentalPrice: String, summary: String, image: String, rights: String, link: String, rank: Int) {
        self.name = name
        self.releaseDate = releaseDate
        self.purchasePrice = purchasePrice
        self.rentalPrice = rentalPrice
        self.summary = summary
        self.image = image
        self.rights = rights
        self.link = link
        self.rank = rank
        self.key = ""
        self.itemRef = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        itemRef = snapshot.ref
        
        if let movieName = (snapshot.value! as! NSDictionary).value(forKey: "name") as? String {
            name = movieName
        } else {
            name = ""
        }
        
        if let movieReleaseDate = (snapshot.value! as! NSDictionary).value(forKey: "releaseDate") as? String {
            releaseDate = movieReleaseDate
        } else {
            releaseDate = ""
        }
        
        if let moviePurchasePrice = (snapshot.value! as! NSDictionary).value(forKey: "purchasePrice") as? String {
            purchasePrice = moviePurchasePrice
        } else {
            purchasePrice = ""
        }
        
        if let movieRentalPrice = (snapshot.value! as! NSDictionary).value(forKey: "rentalPrice") as? String {
            rentalPrice = movieRentalPrice
        } else {
            rentalPrice = ""
        }
        
        if let movieSummary = (snapshot.value! as! NSDictionary).value(forKey: "summary") as? String {
            summary = movieSummary
        } else {
            summary = ""
        }
        
        if let movieImage = (snapshot.value! as! NSDictionary).value(forKey: "image") as? String {
            image = movieImage
        } else {
            image = ""
        }
        
        if let movieRights = (snapshot.value! as! NSDictionary).value(forKey: "rights") as? String {
            rights = movieRights
        } else {
            rights = ""
        }
        
        if let movieLink = (snapshot.value! as! NSDictionary).value(forKey: "link") as? String {
            link = movieLink
        } else {
            link = ""
        }
        
        if let movieRank = (snapshot.value! as! NSDictionary).value(forKey: "rank") as? Int {
            rank = movieRank
        } else {
            rank = 100
        }
    }
    
    func toAnyObject() -> AnyObject {
        return ["name": name,
                "releaseDate": releaseDate,
                "purchasePrice": purchasePrice,
                "rentalPrice": rentalPrice,
                "summary": summary,
                "image": image,
                "rights": rights,
                "link": link,
                "rank": rank] as AnyObject
    }
    
}
