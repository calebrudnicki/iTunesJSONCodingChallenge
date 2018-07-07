//
//  FavoritesViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/23/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var movies: [Movies] = []
    
    //This function sets up the table view and calls retrieveFromCoreData() and decideToShowNoFavoritesLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = false
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.tableFooterView = UIView()
        self.retrieveFromCoreData()
        self.decideToShowNoFavoritesLabel()
    }
    
    //This function calls reorderCoreData() when the back button is tapped
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.reorderCoreData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This function decides whether or not the user has any favorite movies and displays the page accordingly
    func decideToShowNoFavoritesLabel() {
        if movies.count > 0 {
            self.noFavoritesLabel.isHidden = true
            self.tableView.isHidden = false
        } else {
            self.noFavoritesLabel.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    //MARK: CoreData Functions
    
    //This function retrieves the movies from CoreData
    func retrieveFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Movies")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    self.movies.append(result as! Movies)
                }
            }
        } catch let error as NSError {
            fatalError("Failed to retrieve movie: \(error)")
        }
    }
    
    //This function deletes a specific movie from CoreData
    func deleteFromCoreData(_ indexPath: IndexPath) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context = appDelegate.persistentContainer.viewContext
        let movieToBeDeleted = movies[(indexPath as NSIndexPath).row]
        context.delete(movieToBeDeleted)
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Failed to fetch movie: \(error)")
        }
    }
    
    //This function reorders the values in core data to account for the user's top list of movies
    func reorderCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        if movies.count > 1 {
            for i in 0...movies.count - 1 {
                let currentMovie = NSEntityDescription.insertNewObject(forEntityName: "Movies", into: context)
                currentMovie.setValue(self.movies[i].name, forKey: "name")
                currentMovie.setValue(self.movies[i].releaseDate, forKey: "releaseDate")
                currentMovie.setValue(self.movies[i].price, forKey: "price")
                currentMovie.setValue(self.movies[i].image, forKey: "image")
                currentMovie.setValue(self.movies[i].link, forKey: "link")
                context.delete(self.movies[i])
                
                do {
                    try context.save()
                } catch let error as NSError {
                    fatalError("Failed to reorder movies: \(error)")
                }
            }
            print("REORDERED") 
        }
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
        cell.titleLabel.text = self.movies[indexPath.row].name
        cell.releaseDateLabel.text = self.movies[indexPath.row].releaseDate
        if let priceDefault = UserDefaults.standard.object(forKey: "isSeeingRentalPrice") as? Bool {
            if priceDefault == true && self.movies[indexPath.row].rentalPrice != nil {
                cell.priceLabel.text = "Rent: " + self.movies[indexPath.row].rentalPrice!
            } else {
                cell.priceLabel.text = "Purchase: " + self.movies[indexPath.row].price!
            }
        }
        return cell
    }
    
    //This delegate function allows the user to delete a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteFromCoreData(indexPath)
            self.movies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
            if movies.count < 1 {
                decideToShowNoFavoritesLabel()
            }
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
    
    //This delegate function recognizes the cell that was selected and then performs a segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showFavoriteMovieDetails", sender: movies[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
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
