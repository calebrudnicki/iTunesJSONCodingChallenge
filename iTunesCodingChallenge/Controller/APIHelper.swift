//
//  APIHelper.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/23/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import SwiftyJSON

class APIHelper {
    
    //This functions fetches and parses the JSON object and returns a list of movies
    func readJSONObj(object: [String: AnyObject]) -> [Movie] {
        var movieList: [Movie] = []
        guard let movies = object["feed"]!["entry"] as? [[String: AnyObject]] else { return movieList }
        
        for movie in movies {
            
            guard let name = movie["im:name"]!["label"] ?? "",
                var releaseDate = movie["im:releaseDate"]?["label"] ?? "",
                let purchasePrice = movie["im:price"]!["label"],
                let rentalPrice = movie["im:rentalPrice"]?["label"] ?? "",
                let summary = movie["summary"]?["label"] ?? "",
                let imageDictionary = movie["im:image"] as? [NSDictionary],
                let image = imageDictionary[2]["label"],
                let rights = movie["rights"]?["label"] ?? "",
                let linkDictionary = movie["link"] as? [NSDictionary],
                let attributesDictionary = linkDictionary[1]["attributes"] as? NSDictionary,
                let link = attributesDictionary["href"] else { break }
            
            releaseDate = self.outputFormatter.string(from: ISO8601DateFormatter().date(from: releaseDate as! String)!)
            
            let newMovie = Movie(name: name as! String, releaseDate: releaseDate as! String, purchasePrice: purchasePrice as! String, rentalPrice: rentalPrice as! String, summary: summary as! String, image: image as! String, rights: rights as! String, link: link as! String, rank: 0)
            movieList.append(newMovie)
        }
        
        return movieList
        
    }
    
    //MARK: Helper Functions
    
    //This block of code formats the date into a MMMM dd, yyyy format
    let outputFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
}
