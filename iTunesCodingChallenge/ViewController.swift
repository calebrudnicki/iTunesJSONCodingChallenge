//
//  ViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/20/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//
//  App icon designed by Shastry from the Noun Project
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    typealias JSONDictionary = [String:Any]
    var movies = [Movie]()
    
    //This is a movie struct with five string attributes
    struct Movie {
        let name, price, releaseDate, image, link : String
    }
    
    //This block of code formats the date into a MMMM dd, yyyy format
    let outputFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    //This function sets up the table view, url, and then calls fetchJSON() when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let url = URL(string: "https://itunes.apple.com/us/rss/topmovies/limit=25/json")!
        self.fetchJSON(url: url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This functions searches into the JSON file by key and pulls out a value at that key
    func labelValue(for key : String, in dict : JSONDictionary) -> String {
        guard let temp = dict["im:" + key] as? JSONDictionary else { return "" }
        return temp["label"] as? String ?? ""
    }
    
    //This functions fetches from the JSON file and creates new movie objects before adding each of them into the array of Movie objects
    func fetchJSON(url: URL) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    if let parsedData = try JSONSerialization.jsonObject(with:data!) as? JSONDictionary {
                        if let feed = parsedData["feed"] as? JSONDictionary, let entries = feed["entry"] as? [JSONDictionary] {
                            for entry in entries {
                                var image = ""
                                if let images = entry["im:image"] as? [JSONDictionary], !images.isEmpty {
                                    image = images[0]["label"] as? String ?? ""
                                }
                                var link = ""
                                if let links = entry["link"] as? [JSONDictionary] {
                                    let attributes = links.flatMap({ $0["attributes"] as? JSONDictionary })
                                    if let attribute = attributes.filter({ ($0["type"] as? String) == "text/html" }).first {
                                        link = attribute["href"] as? String ?? ""
                                    }
                                }
                                let name = self.labelValue(for: "name", in: entry)
                                let price = self.labelValue(for: "price", in: entry)
                                let releaseISODate = self.labelValue(for: "releaseDate", in: entry)
                                let releaseDate = ISO8601DateFormatter().date(from: releaseISODate)!
                                let newMovie = Movie(name: name, price: price, releaseDate: self.outputFormatter.string(from: releaseDate), image:image, link:link)
                                self.movies.append(newMovie)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    //MARK: TableView Delegate Functions
    
    //This delegate function sets the amount of rows in the table view to 25
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    //This delegate functions sets data in each cell to the appropriate movie name, date, and price
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.titleLabel.text = self.movies[indexPath.row].name
        cell.releaseDateLabel.text = self.movies[indexPath.row].releaseDate
        cell.priceLabel.text = self.movies[indexPath.row].price
        return cell
    }
    
    //This delegate function recognizes the cell that was selected and then performs a segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMovieDetails", sender: self.movies[indexPath.row].name)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Segue Functions
    
    //This overriden functions is enacted right before the segue is performed so it can feed the necessary data into the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showMovieDetails" {
                let indexPath = tableView.indexPathForSelectedRow!
                let movie = self.movies[indexPath.row]
                let movieDetailViewController = segue.destination as! MovieDetailViewController
                movieDetailViewController.movieName = movie.name
                movieDetailViewController.movieReleaseDate = movie.releaseDate
                movieDetailViewController.moviePrice = movie.price
                movieDetailViewController.movieLink = movie.link
                movieDetailViewController.moviePoster = movie.image
            }
        }
    }
    
}
