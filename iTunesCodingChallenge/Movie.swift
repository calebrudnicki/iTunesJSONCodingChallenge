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
    private var rentalPrice: String?
    private var summary: String?
    private var image: String?
    private var rights: String?
    private var link: String?
    
    init(name: String, releaseDate: String, price: String, rentalPrice: String, summary: String, image: String, rights: String, link: String) {
        self.name = name
        self.releaseDate = releaseDate
        self.price = price
        self.rentalPrice = rentalPrice
        self.summary = summary
        self.image = image
        self.rights = rights
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
    
    //This function returns the rental price of the movie
    public func getRentalPrice() -> String {
        return rentalPrice!
    }
    
    //This function returns the summary of the movie
    public func getSummary() -> String {
        return summary!
    }

    //This function returns the image of the movie
    public func getImage() -> String {
        return image!
    }
    
    //This function returns the right of the movie
    public func getRights() -> String {
        return rights!
    }
    
    //This function returns the link of the movie
    public func getLink() -> String {
        return link!
    }
}
