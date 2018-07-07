//
//  ViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/20/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//
//  App icon designed by Blaise Sewell from the Noun Project
//  Finger icons designed by Andrejs Kirma from the Noun Project
//

import UIKit
import CoreData
import UserNotifications
import CDAlertView

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let apiHelper = APIHelper()
    var movies = [Movie]()
    var refreshControl = UIRefreshControl()
    
    //This function sets up the table view, activity indicator, current date label, and calls setCurrentDate(), fetchJSON()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.currentDateLabel.text = ""
        self.title = "Top \(String(describing: UserDefaults.standard.object(forKey: "numberOfMovies")!))"
        self.refreshControl.addTarget(self, action: #selector(ViewController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
        self.sparkJSONCall()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This function removes itself as an observer when the view disappears
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //This function reloads the table view every time the view appears
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //This function calls for the reach to the endpoint as long as there is internet
    func sparkJSONCall() {
        self.movies = []
        let url = URL(string: "https://itunes.apple.com/us/rss/topmovies/limit=\(String(describing: UserDefaults.standard.object(forKey: "numberOfMovies")!))/json")!
        let data = NSData(contentsOf: url)
        do {

            if data != nil {
                
                let object = try JSONSerialization.jsonObject(with: (data as Data?)!, options: .allowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    self.movies = apiHelper.readJSONObj(object: dictionary)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicatorLabel.text = ""
                    self.setCurrentDate()
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicatorLabel.text = "Couldn't connect to server, pull down to refresh"
                    self.refreshControl.endRefreshing()
                }
                self.promptUserToRefetchJSON()
                
            }
            
        } catch {
            print("Error occured")
        }
    }
    
    //This function handles the refreshing of the data from the API
    func refreshData() {
        self.movies.removeAll()
        self.sparkJSONCall()
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
        let alert = CDAlertView(title: nil, message: "Seems like you don't have an internet connection. Would you like to try to reconnect?", type: .error)
        let reconnectAction = CDAlertViewAction(title: "Reconnect", font: UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin), textColor: UIColor.red, backgroundColor: UIColor.black, handler: { (action: CDAlertViewAction) -> Bool in
            self.sparkJSONCall()
            return true
        })
        let cancelAction = CDAlertViewAction(title: "Cancel", font: UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin), textColor: UIColor.red, backgroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), handler: nil)
        alert.add(action: reconnectAction)
        alert.add(action: cancelAction)
        alert.show()
    }
    
    //MARK: CoreData Functions
    
    //This function adds a movie to CoreData as one of the users favorite movies and send them a notification
    func addMovieToFavorites(_ indexPath: NSIndexPath) {
        let context = appDelegate.persistentContainer.viewContext
        let newFavoriteMovie = NSEntityDescription.insertNewObject(forEntityName: "Movies", into: context)
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getName(), forKey: "name")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getReleaseDate(), forKey: "releaseDate")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getPurchasePrice(), forKey: "price")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getRentalPrice(), forKey: "rentalPrice")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getSummary(), forKey: "summary")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getRights(), forKey: "rights")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getImage(), forKey: "image")
        newFavoriteMovie.setValue(self.movies[(indexPath as NSIndexPath).row].getLink(), forKey: "link")
        
        do {
            try context.save()
            print("Saved " + self.movies[(indexPath as NSIndexPath).row].getName() + " to CoreData")
            self.sendUserNotification(movieName: self.movies[(indexPath as NSIndexPath).row].getName(), movieImage: self.movies[(indexPath as NSIndexPath).row].getImage())
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
        if let priceDefault = UserDefaults.standard.object(forKey: "isSeeingRentalPrice") as? Bool {
            if priceDefault == true && self.movies[indexPath.row].getRentalPrice() != "" {
                cell.priceLabel.text = "Rent: " + self.movies[indexPath.row].getRentalPrice()
            } else {
                cell.priceLabel.text = "Purchase: " + self.movies[indexPath.row].getPurchasePrice()
            }
        }
        return cell
    }
    
    //This delegate function recognizes the cell that was selected and then performs a segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMovieDetails", sender: self.movies[indexPath.row].getName())
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //This delegate function allows the user to slide over an a cell to add it to favorites if it isn't already added to favorites
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let addToFavorites = UITableViewRowAction(style: .default, title: "Add Movie") { action, index in
            self.tableView.isEditing = false
            var alert = CDAlertView()
            if self.foundDuplicateInCoreData(movieName: self.movies[editActionsForRowAt.row].getName()) {
                alert = CDAlertView(title: "Sorry", message: self.movies[editActionsForRowAt.row].getName() + " was already added", type: .warning)
            } else {
                self.addMovieToFavorites(editActionsForRowAt as NSIndexPath)
                alert = CDAlertView(title: "Added!", message: self.movies[editActionsForRowAt.row].getName() + " had been added to your favorites", type: .success)
            }
            let dismissAction = CDAlertViewAction(title: "Dismiss", font: UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin), textColor: UIColor.red, backgroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), handler: nil)
            alert.add(action: dismissAction)
            alert.autoHideTime = 2.5
            alert.hasRoundCorners = true
            alert.show()
        }
        addToFavorites.backgroundColor = UIColor(colorLiteralRed: 57/255, green: 172/255, blue: 160/255, alpha: 1)
        return [addToFavorites]
    }
    
    //MARK: Notification Functions
    
    //Sends the user a notification about a movie that was added to their favorites list
    func sendUserNotification(movieName: String, movieImage: String) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "You added " + movieName, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Check it out on your favorites list!", arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = 1
        
        //Deliver the notification
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 7200, repeats: false)
        let request = UNNotificationRequest.init(identifier: "TwoHour", content: content, trigger: trigger)
        
        //Schedule the notification
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
    
    //MARK: Action Functions
    
    //This function lets the user toggle between purchase and rental price when the help icon is tapped
    @IBAction func settingsButtonTapped(_ sender: Any) {
        let alert = CDAlertView(title: "Settings", message: "Toggle between price rates and change the number of movies in the list...", type: .custom(image: #imageLiteral(resourceName: "HelpIcon")))
        
        let priceSegmentedController = UISegmentedControl()
        priceSegmentedController.insertSegment(withTitle: "Purchase", at: 0, animated: false)
        priceSegmentedController.insertSegment(withTitle: "Rental", at: 1, animated: false)
        
        if let priceDefault = UserDefaults.standard.object(forKey: "isSeeingRentalPrice") as? Int {
            priceSegmentedController.selectedSegmentIndex = priceDefault
        }
        
        let countSegmentedController = UISegmentedControl()
        countSegmentedController.insertSegment(withTitle: "10", at: 0, animated: false)
        countSegmentedController.insertSegment(withTitle: "25", at: 1, animated: false)
        countSegmentedController.insertSegment(withTitle: "50", at: 2, animated: false)
        countSegmentedController.insertSegment(withTitle: "100", at: 3, animated: false)
        
        if let numberDefault = UserDefaults.standard.object(forKey: "numberOfMovies") as? Int {
            switch numberDefault {
            case 10:
                countSegmentedController.selectedSegmentIndex = 0
            case 25:
                countSegmentedController.selectedSegmentIndex = 1
            case 50:
                countSegmentedController.selectedSegmentIndex = 2
            case 100:
                countSegmentedController.selectedSegmentIndex = 3
            default:
                countSegmentedController.selectedSegmentIndex = 1
            }
        }
        
        
        let stackView = UIStackView(arrangedSubviews: [priceSegmentedController, countSegmentedController])
        stackView.axis = .vertical
        stackView.spacing = 5.0
        
        
        alert.customView = stackView
        let dismissAction = CDAlertViewAction(title: "Dismiss", font: UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin), textColor: UIColor.red, backgroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), handler: { (action: CDAlertViewAction) -> Bool in
            
            if priceSegmentedController.selectedSegmentIndex == 0 {
                UserDefaults.standard.set(false, forKey: "isSeeingRentalPrice")
            } else {
                UserDefaults.standard.set(true, forKey: "isSeeingRentalPrice")
            }
            
            switch countSegmentedController.selectedSegmentIndex {
            case 0:
                UserDefaults.standard.set(10, forKey: "numberOfMovies")
                self.title = "Top 10"
            case 1:
                UserDefaults.standard.set(25, forKey: "numberOfMovies")
                self.title = "Top 25"
            case 2:
                UserDefaults.standard.set(50, forKey: "numberOfMovies")
                self.title = "Top 50"
            case 3:
                UserDefaults.standard.set(100, forKey: "numberOfMovies")
                self.title = "Top 100"
            default:
                UserDefaults.standard.set(25, forKey: "numberOfMovies")
                self.title = "Top 25"
            }
            
            self.sparkJSONCall()
            self.tableView.reloadData()
            return true
        })
        alert.add(action: dismissAction)
        alert.show()
    }
    
}
