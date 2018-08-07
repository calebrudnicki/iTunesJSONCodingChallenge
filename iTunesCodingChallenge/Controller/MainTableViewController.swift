//
//  ViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/20/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import CDAlertView
import PopMenu
import FirebaseAuth
import FirebaseDatabase

class MainTableViewController: UITableViewController {
    
    var user: AppUser?
    let apiHelper = APIHelper()
    var movies = [Movie]()
    var firebaseMovies: [Movie] = []
    var dbRef: DatabaseReference!
    
    let movieCountPopManager = PopMenuManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movies = sparkJSONCall()
        tableView.separatorStyle = .none
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "cell")
        let settingsButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(settingsButtonTapped(_:)))
        let profileButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(profileButtonTapped(_:)))
        navigationItem.leftBarButtonItems = [settingsButton, profileButton]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(favoritesButtonTapped(_:)))
        navigationItem.title = PopMenuHelper().translateNumberOptionsForTitle()
        
//        movieCountPopManager.actions = [
//            PopMenuDefaultAction(title: "Top 10"),
//            PopMenuDefaultAction(title: "Top 25"),
//            PopMenuDefaultAction(title: "Top 50"),
//            PopMenuDefaultAction(title: "Top 100")
//        ]
//        movieCountPopManager.present(sourceView: navigationItem.leftBarButtonItem)
        if let uid = Auth.auth().currentUser?.uid {
            self.dbRef = Database.database().reference().child(uid)
        }
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
    
    //This function calls for the reach to the endpoint as long as there is internet
    func sparkJSONCall() -> [Movie] {
        let url = URL(string: "https://itunes.apple.com/us/rss/topmovies/limit=\(String(describing: UserDefaults.standard.object(forKey: "numberOfMovies")!))/json")!
        let data = NSData(contentsOf: url)
        do {
            if data != nil {
                let object = try JSONSerialization.jsonObject(with: (data as Data?)!, options: .allowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    return apiHelper.readJSONObj(object: dictionary)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
//                let movie = Movie(name: "Back to the future",
//                                  releaseDate: "December 15, 1996nqwioefnqoiwe fqiwebfibqwief qweif qwieuf uqwefi qweif iuqw efjqnewfiuqwevfiqw efiqevfyuiqw eflqef, qm ewfuy ewrwerg qruiglqwbrkgq wierg uqw .", purchasePrice: "$19.99", rentalPrice: "$5.99", summary: "This is a summary.", image: "imageString", rights: "Property of Warner Brothers", link: "movielink", rank: 1)
//                return [movie]
                self.promptUserToRefetchJSON()
            }
        } catch {
            print("Error occured")
        }
        return []
    }
    
    //This function handles the refreshing of the data from the API
    func refreshData() {
        movies.removeAll()
        movies = sparkJSONCall()
    }
    
    //This functions displays an alert controller to allow the user to try to reconnect to the API if they couldn't originally
    func promptUserToRefetchJSON() {
        let alert = CDAlertView(title: nil, message: "Seems like you don't have an internet connection. Would you like to try to reconnect?", type: .error)
        let reconnectAction = CDAlertViewAction(title: "Reconnect", font: UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin), textColor: UIColor.red, backgroundColor: UIColor.black, handler: { (action: CDAlertViewAction) -> Bool in
            self.movies = self.sparkJSONCall()
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
    
    //MARK: Action Functions
    
    @objc func settingsButtonTapped(_ sender: Any) {
        let manager = PopMenuManager.default
        manager.popMenuAppearance.popMenuColor.backgroundColor = .gradient(fill: .black, .blue)
        manager.actions = PopMenuHelper().presentNumberOptions()
        manager.present(sourceView: navigationItem.leftBarButtonItem)
        //CR: This doesn't work on the first call
        manager.popMenuDidDismiss = { selected in
            self.title = PopMenuHelper().translateNumberOptionsForTitle()
        }
        movies = sparkJSONCall()
        tableView.reloadData()
    }
    
    @objc func profileButtonTapped(_ sender: Any) {
    
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
                    print(error?.localizedDescription ?? "")
                }
            })
        }))
        self.present(userAlert, animated: true, completion: nil)
    }
    
    @objc func favoritesButtonTapped(_ sender: Any) {
        self.navigationController?.pushViewController(FavoritesViewController(), animated: true)
    }
    
}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? MovieTableViewCell {
            cell.display(rank: indexPath.row + 1, movie: movies[indexPath.row])
            cell.delegate = self
        }
        return cell
    }
    
}

extension MainTableViewController: MovieTableViewCellDelegate {
    
    func movieTableViewCellDidAddMovieToFavorites(movie: Movie) {
        var alert = CDAlertView()
        if self.foundDuplicateInFirebase(movieName: movie.name!) {
            alert = CDAlertView(title: "Sorry", message: movie.name! + " was already added", type: .warning)
        } else {
            let movieRef = self.dbRef.child((movie.name?.lowercased())!)
            movieRef.setValue(movie.toAnyObject())
            alert = CDAlertView(title: "Added!", message: movie.name! + " had been added to your favorites", type: .success)
        }
        let dismissAction = CDAlertViewAction(title: "Dismiss", font: UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin), textColor: UIColor.red, backgroundColor: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1), handler: nil)
        alert.add(action: dismissAction)
        alert.autoHideTime = 2.5
        alert.hasRoundCorners = true
        alert.show()
    }

}
