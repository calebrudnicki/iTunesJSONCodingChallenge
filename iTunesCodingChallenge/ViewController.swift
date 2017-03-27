//
//  ViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/20/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//
//  App icon designed by Blaise Sewell from the Noun Project
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    typealias JSONDictionary = [String : Any]
    var movies = [Movie]()
    var refreshControl = UIRefreshControl()
    let url = URL(string: "https://itunes.apple.com/us/rss/topmovies/limit=25/json")!
    
    //This function sets up the table view, activity indicator, and calls setCurrentDate() and fetchJSON()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ViewController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
        self.setCurrentDate()
        self.fetchJSON(url: url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This functions fetches from the JSON file and creates new movie objects before adding each of them into the array of Movie objects
    func fetchJSON(url: URL) {
        self.activityIndicator.startAnimating()
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.activityIndicator.stopAnimating()
                self.promptUserToRefetchJSON()
                print(error!)
            } else {
                do {
                    //Set the variable parsedData if the JSON object can be cast as a dictionary
                    if let parsedData = try JSONSerialization.jsonObject(with:data!) as? JSONDictionary {
                        //Split the JSON fil up into two dictionaries, feed and entry
                        if let feed = parsedData["feed"] as? JSONDictionary, let entries = feed["entry"] as? [JSONDictionary] {
                            //Loop thru the entry array of dictionaries as it is where the movie info is
                            for entry in entries {
                                //Get the string of the image by getting the value at the key im:image
                                var image = ""
                                if let images = entry["im:image"] as? [JSONDictionary], !images.isEmpty {
                                    image = images[0]["label"] as? String ?? ""
                                }
                                //Get the string of the link by getting the value at the key href
                                var link = ""
                                if let links = entry["link"] as? [JSONDictionary] {
                                    let attributes = links.flatMap({ $0["attributes"] as? JSONDictionary })
                                    if let attribute = attributes.filter({ ($0["type"] as? String) == "text/html" }).first {
                                        link = attribute["href"] as? String ?? ""
                                    }
                                }
                                //Get the name, price, and release date by calling getValue()
                                let name = self.getValue(for: "name", in: entry)
                                let price = self.getValue(for: "price", in: entry)
                                let releaseISODate = self.getValue(for: "releaseDate", in: entry)
                                let releaseDate = ISO8601DateFormatter().date(from: releaseISODate)!
                                //Create a new movie object and save it into core data
                                let newMovie = Movie(name: name, releaseDate: self.outputFormatter.string(from: releaseDate), price: price, image:image, link:link)
                                self.movies.append(newMovie)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    //This functions searches into the JSON file by im:key and pulls out a value at that key
    func getValue(for key : String, in dict : JSONDictionary) -> String {
        guard let temp = dict["im:" + key] as? JSONDictionary else { return "" }
        return temp["label"] as? String ?? ""
    }
    
    //This block of code formats the date into a MMMM dd, yyyy format
    let outputFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    //This function handles the refreshing of the data from the API
    func refreshData() {
        self.movies.removeAll()
        self.setCurrentDate()
        self.fetchJSON(url: url)
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    //This function gets the current date and sets the label at the bottom of the table view
    func setCurrentDate() {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        self.currentDateLabel.text = "Last updated on " + String(describing: components.month!) + "/" + String(describing: components.day!) + "/" + String(describing: components.year!) + " at " + String(describing: components.hour!) + ":" + String(describing: components.minute!) + ":" + String(describing: components.second!)
    }
    
    //This functions displays an alert controller to allow the user to try to reconnect to the API if they couldn't originally
    func promptUserToRefetchJSON() {
        let alertController = UIAlertController(title: nil, message: "Seems like you don't have an internet connection. Would you like to try to reconnect?", preferredStyle: .actionSheet)
        let reconnectAction = UIAlertAction(title: "Attempt a reconnect", style: .default) { (action) in
            self.fetchJSON(url: self.url)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(reconnectAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: CoreData Functions
    
    //This function adds a movie to CoreData as one of the users favorite movies
    func addMovieToFavorites(_ indexPath: NSIndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newFavoriteMovie = NSEntityDescription.insertNewObject(forEntityName: "Movies", into: context)
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getName(), forKey: "name")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getReleaseDate(), forKey: "releaseDate")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getPrice(), forKey: "price")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getImage(), forKey: "image")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getLink(), forKey: "link")
        
        do {
            try context.save()
            print("SAVED")
        } catch let error as NSError {
            fatalError("Failed to add movie to favorites: \(error)")
        }
        self.tableView.setEditing(false, animated: true)
    }
    
    //This function checks to see if a movie is already in a user's favorites in CoreData
    func foundDuplicateInCoreData(movieName: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Movies")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
                for result in results as! [NSManagedObject] {
                    if (result as! Movies).name == movieName {
                        return true
                    }
            }
        } catch let error as NSError {
            fatalError("Failed to retrieve movie: \(error)")
        }
        return false
    }
    
    //MARK: TableView Delegate Functions
    
    //This delegate function sets the amount of rows in the table view to 25
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    //This delegate functions sets data in each cell to the appropriate movie rank, name, date, and price
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.rankLabel.text = String(indexPath.row + 1)
        cell.titleLabel.text = self.movies[indexPath.row].getName()
        cell.releaseDateLabel.text = self.movies[indexPath.row].getReleaseDate()
        cell.priceLabel.text = self.movies[indexPath.row].getPrice()
        return cell
    }
    
    //This delegate function recognizes the cell that was selected and then performs a segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        performSegue(withIdentifier: "showMovieDetails", sender: self.movies[indexPath.row].getName())
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //This delegate function allows the user to slide over an a cell to add it to favorites
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let addToFavorites = UITableViewRowAction(style: .default, title: "Add Movie") { action, index in
            if self.foundDuplicateInCoreData(movieName: self.movies[editActionsForRowAt.row].getName()) {
                print("Didnt work")
            } else {
                print("Worked")
                self.addMovieToFavorites(editActionsForRowAt as NSIndexPath)
            }
            //self.addMovieToFavorites(editActionsForRowAt as NSIndexPath)
        }
        addToFavorites.backgroundColor = UIColor(colorLiteralRed: 57/255, green: 172/255, blue: 160/255, alpha: 1)
        return [addToFavorites]
    }
    
    //MARK: Segue Functions
    
    //This overriden functions is enacted right before the segue is performed so it can feed the movie object thru the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showMovieDetails" {
                let indexPath = tableView.indexPathForSelectedRow!
                let movie = self.movies[indexPath.row]
                let movieDetailViewController = segue.destination as! MovieDetailViewController
                movieDetailViewController.movie = movie
            }
        }
    }
    
}
