//
//  Movie.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/23/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import Foundation

class Movie {
    
    private var name: String?
    private var releaseDate: String?
    private var price: String?
    private var image: String?
    private var link: String?
    
    init(name: String, releaseDate: String, price: String, image: String, link: String) {
        self.name = name
        self.releaseDate = releaseDate
        self.price = price
        self.image = image
        self.link = link
    }
    
    //This function returns the name of the movie
    public func getName() -> String {
        return name!
    }
    
    //This function returns the release date of the movie
    public func getReleaseDate() -> String {
        return releaseDate!
    }
    
    //This function returns the price of the movie
    public func getPrice() -> String {
        return price!
    }
    
    //This function returns the image of the movie
    public func getImage() -> String {
        return image!
    }
    
    //This function returns the link of the movie
    public func getLink() -> String {
        return link!
    }
}
