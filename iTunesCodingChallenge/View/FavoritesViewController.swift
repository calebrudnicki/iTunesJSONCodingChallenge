//
//  FavoritesViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/23/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var movies: [Movie] = []
    var dbRef: DatabaseReference!
    
    //This function sets up the table view and calls retrieveFromCoreData() and decideToShowNoFavoritesLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = false
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.tableFooterView = UIView()
        dbRef = Database.database().reference().child("movies")
        startObservingDatabase() //CR: This allows the tableview to listen to changes in the database and automatically update
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
        print("reorder")
    }

    //MARK: TableView Delegate Functions
    
    //This delegate function sets the amount of rows in the table view to the total amount of favorited movies
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    //This delegate function sets data in each cell to the appropriate movie rank, name, date, and price
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.rankLabel.text = String(indexPath.row + 1)
        cell.titleLabel.text = self.movies[indexPath.row].name!
        cell.releaseDateLabel.text = self.movies[indexPath.row].releaseDate!
        if let priceDefault = UserDefaults.standard.object(forKey: "isSeeingRentalPrice") as? Bool {
            if priceDefault == true && self.movies[indexPath.row].rentalPrice != nil {
                cell.priceLabel.text = "Rent: " + self.movies[indexPath.row].rentalPrice!
            } else {
                cell.priceLabel.text = "Purchase: " + self.movies[indexPath.row].purchasePrice!
            }
        }
        return cell
    }
    
    //This delegate function allows the user to delete a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = movies[indexPath.row]
            movie.itemRef?.removeValue()
            self.movies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    //This delegate function allows the user to swipe on the cell and watch the movie's trailer
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let watchTrailer = UITableViewRowAction(style: .default, title: "Watch Trailer", handler: { action, index in
            self.tableView.isEditing = false
            let url = URL(string: (self.movies[editActionsForRowAt.row].link)!)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(url)
            }
        })
        watchTrailer.backgroundColor = UIColor(colorLiteralRed: 57/255, green: 172/255, blue: 160/255, alpha: 1)
        if self.tableView.isEditing {
            return nil
        }
        return [watchTrailer]
    }
    
    //This delegate function allows the user to reorder their favorites list but doesn't change anything in CoreData until the view disappears
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movieToBeMoved = movies[sourceIndexPath.row]
        self.movies.remove(at: sourceIndexPath.row)
        self.movies.insert(movieToBeMoved, at: destinationIndexPath.row)
        self.tableView.reloadData()
    }

    //MARK: Action Functions
    
    //This function toggles between editing the table view and not editing the table view when the edit button is pressed
    @IBAction func editButtonTapped(_ sender: Any) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        if editButton.title == "Edit" {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
    }

}
