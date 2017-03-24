//
//  FavoritesViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/23/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: TableView Delegate Functions
    
    //This delegate function sets the amount of rows in the table view to the total amount of favorited movies
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMovies.count
    }
    
    //This delegate function sets data in each cell to the appropriate movie rank, name, date, and price
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.rankLabel.text = String(indexPath.row + 1)
        cell.titleLabel.text = favoriteMovies[indexPath.row].getName()
        cell.releaseDateLabel.text = favoriteMovies[indexPath.row].getReleaseDate()
        cell.priceLabel.text = favoriteMovies[indexPath.row].getPrice()
        return cell
    }
    
    //This delegate function allows the user to delete a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            favoriteMovies.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    //This delegate function allows the user to reorder their favorites list
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = favoriteMovies[sourceIndexPath.row]
        favoriteMovies.remove(at: sourceIndexPath.row)
        favoriteMovies.insert(movedObject, at: destinationIndexPath.row)
        self.tableView.reloadData()
    }

}
