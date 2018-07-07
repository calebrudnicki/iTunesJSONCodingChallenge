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
import CDAlertView
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userEmail: String?
    let apiHelper = APIHelper()
    var movies = [Movie]()
    var firebaseMovies: [Movie] = []
    var refreshControl = UIRefreshControl()
    var dbRef: DatabaseReference!
    
    //This function sets up the table view, activity indicator, current date label, and calls setCurrentDate(), fetchJSON()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sparkJSONCall()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.currentDateLabel.text = ""
        self.title = "Top \(String(describing: UserDefaults.standard.object(forKey: "numberOfMovies")!))"
        self.refreshControl.addTarget(self, action: #selector(ViewController.refreshData), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
        dbRef = Database.database().reference().child("movies")
        startObservingDatabase()
    }
    
    func startObservingDatabase() {
        dbRef!.observe(.value, with: { (snapshot: DataSnapshot) in
            var newMovies = [Movie]()
            for movie in snapshot.children {
                let movieObject = Movie(snapshot: movie as! DataSnapshot)
                newMovies.append(movieObject)
            }
            self.firebaseMovies = newMovies
            self.tableView.reloadData()
        })
    }
    
    //This function reloads the table view every time the view appears
    override func viewDidAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.userEmail = user.email!
                print("Welcome \(String(describing: user.email!))")
            } else {
                print("You need to sign up or login first")
            }
        }
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
        
        self.currentDateLabel.text = "Last updated on " + String(describing: components.month!) + "/" + String(describing: components.day!) + "/" + String(describing: components.year!) + " at " + String(describing: components.hour!) + ":" + String(describing: components.minute!) + ":" + String(describing: components.second!) + " for \(String(describing: userEmail ?? "test"))"
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
    
    func foundDuplicateInFirebase(movieName: String) -> Bool {
        for movie in firebaseMovies {
            if movie.name == movieName {
                return true
            }
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
        cell.titleLabel.text = self.movies[indexPath.row].name!
        cell.releaseDateLabel.text = self.movies[indexPath.row].releaseDate!
        if let priceDefault = UserDefaults.standard.object(forKey: "isSeeingRentalPrice") as? Bool {
            if priceDefault == true && self.movies[indexPath.row].rentalPrice! != "" {
                cell.priceLabel.text = "Rent: " + self.movies[indexPath.row].rentalPrice!
            } else {
                cell.priceLabel.text = "Purchase: " + self.movies[indexPath.row].purchasePrice!
            }
        }
        return cell
    }
    
    //This delegate function recognizes the cell that was selected and then performs a segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMovieDetails", sender: self.movies[indexPath.row].name!)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //This delegate function allows the user to slide over an a cell to add it to favorites if it isn't already added to favorites
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let addToFavorites = UITableViewRowAction(style: .default, title: "Add Movie") { action, index in
            self.tableView.isEditing = false
            var alert = CDAlertView()
            if self.foundDuplicateInFirebase(movieName: self.movies[editActionsForRowAt.row].name!) {
                alert = CDAlertView(title: "Sorry", message: self.movies[editActionsForRowAt.row].name! + " was already added", type: .warning)
            } else {
                let firebaseMovie = Movie(name: self.movies[editActionsForRowAt.row].name!,
                                          releaseDate: self.movies[editActionsForRowAt.row].releaseDate!,
                                          purchasePrice: self.movies[editActionsForRowAt.row].purchasePrice!,
                                          rentalPrice: self.movies[editActionsForRowAt.row].rentalPrice!,
                                          summary: self.movies[editActionsForRowAt.row].summary!,
                                          image: self.movies[editActionsForRowAt.row].image!,
                                          rights: self.movies[editActionsForRowAt.row].rights!,
                                          link: self.movies[editActionsForRowAt.row].link!,
                                          rank: self.firebaseMovies.count + 1)
                let movieRef = self.dbRef.child((self.movies[editActionsForRowAt.row].name!.lowercased()))
                movieRef.setValue(firebaseMovie.toAnyObject())
                alert = CDAlertView(title: "Added!", message: self.movies[editActionsForRowAt.row].name! + " had been added to your favorites", type: .success)
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
        let userAction = CDAlertViewAction(title: "User", font: UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin), textColor: UIColor.green, backgroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), handler: { (action: CDAlertViewAction) -> Bool in
            let userAlert = UIAlertController(title: "Login / Signup", message: "Enter email and password", preferredStyle: .alert)
            userAlert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Email"
            })
            userAlert.addTextField(configurationHandler: { (textField) in
                textField.isSecureTextEntry = true
                textField.placeholder = "Password"
            })
            userAlert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { (action) in
                let emailTextField = userAlert.textFields?.first!
                let passwordTextField = userAlert.textFields?.last!
                Auth.auth().signIn(withEmail: (emailTextField?.text!)!, password: (passwordTextField?.text!)!, completion: { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    }
                })
            }))
            userAlert.addAction(UIAlertAction(title: "Sign up", style: .default, handler: { (action) in
                let emailTextField = userAlert.textFields?.first!
                let passwordTextField = userAlert.textFields?.last!
                Auth.auth().createUser(withEmail: (emailTextField?.text!)!, password: (passwordTextField?.text!)!, completion: { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                })
            }))
            self.present(userAlert, animated: true, completion: nil)
            return true
        })
        
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
        alert.add(action: userAction)
        alert.add(action: dismissAction)
        alert.show()
    }
    
}
