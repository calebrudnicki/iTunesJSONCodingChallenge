//
//  FavoritesViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/23/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseDatabase

class FavoritesViewController: UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var movies: [Movie] = []
    var dbRef: DatabaseReference!
    
    //This function sets up the table view and calls retrieveFromCoreData() and decideToShowNoFavoritesLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = false
        tableView.allowsSelectionDuringEditing = true
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
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
            self.movies = newMovies
            self.movies.sort(by: { $0.rank! < $1.rank! })
            self.tableView.reloadData()
        })
    }
    
    //This function calls reorderCoreData() when the back button is tapped
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.reorderMovies()
        }
    }
    
    func reorderMovies() {
        var rank = 1
        for movie in movies {
            let movieRef = self.dbRef.child((movie.name!.lowercased()))
            let rankRef = movieRef.child("rank")
            rankRef.setValue(rank)
            rank += 1
        }
    }

    //MARK: TableView Delegate Functions
    
    //This delegate function sets the amount of rows in the table view to the total amount of favorited movies
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    //This delegate function sets data in each cell to the appropriate movie rank, name, date, and price
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? MovieTableViewCell {
            cell.display(rank: indexPath.row + 1, movie: movies[indexPath.row])
        }
        return cell
    }
    
    //This delegate function allows the user to delete a cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = movies[indexPath.row]
            movie.itemRef?.removeValue()
            self.movies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    //This delegate function allows the user to swipe on the cell and watch the movie's trailer
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let watchTrailer = UITableViewRowAction(style: .default, title: "Watch Trailer", handler: { action, index in
            self.tableView.isEditing = false
            let url = URL(string: (self.movies[editActionsForRowAt.row].link)!)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(url)
            }
        })
        watchTrailer.backgroundColor = UIColor(red: 57/255, green: 172/255, blue: 160/255, alpha: 1)
        if tableView.isEditing {
            return nil
        }
        return [watchTrailer]
    }
    
    //This delegate function allows the user to reorder their favorites list but doesn't change anything in CoreData until the view disappears
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movieToBeMoved = movies[sourceIndexPath.row]
        movies.remove(at: sourceIndexPath.row)
        movies.insert(movieToBeMoved, at: destinationIndexPath.row)
        tableView.reloadData()
    }

    //MARK: Action Functions
    
    //This function toggles between editing the table view and not editing the table view when the edit button is pressed
    @objc func editButtonTapped(_ sender: Any) {
        tableView.setEditing(!self.tableView.isEditing, animated: true)
//        if editButton.title == "Edit" {
//            editButton.title = "Done"
//        } else {
//            editButton.title = "Edit"
//        }
    }

}
