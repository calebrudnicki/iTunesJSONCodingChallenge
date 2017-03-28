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
    
    var movies: [Movies] = []
    
    //This function sets up the table view and calls retrieveFromCoreData()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = true
        self.tableView.allowsSelectionDuringEditing = true
        self.retrieveFromCoreData()
    }
    
    //This function calls reorderCoreData() when the view disappears
    override func viewDidDisappear(_ animated: Bool) {
        self.reorderCoreData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        cell.priceLabel.text = self.movies[indexPath.row].price
        return cell
    }
    
    //This delegate function allows the user to delete a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteFromCoreData(indexPath)
            self.movies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    //This delegate function recognizes the cell that was selected and then performs a segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showFavoriteMovieDetails", sender: self.movies[indexPath.row].name!)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //This delegate function allows the user to reorder their favorites list but doesn't change anything in CoreData until the view disappears
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movieToBeMoved = movies[sourceIndexPath.row]
        self.movies.remove(at: sourceIndexPath.row)
        self.movies.insert(movieToBeMoved, at: destinationIndexPath.row)
        self.tableView.reloadData()
    }
    
    //MARK: Segue Functions
    
    //This overriden functions is enacted right before the segue is performed so it can feed the movie object thru the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showFavoriteMovieDetails" {
                let indexPath = tableView.indexPathForSelectedRow!
                let movieDetailViewController = segue.destination as! MovieDetailViewController
                let chosenMovie = Movie(name: self.movies[indexPath.row].name!, releaseDate: self.movies[indexPath.row].releaseDate!, price: self.movies[indexPath.row].price!, image: self.movies[indexPath.row].image!, link: self.movies[indexPath.row].link!)
                movieDetailViewController.movie = chosenMovie
            }
        }
    }

}
