//
//  MovieDetailViewController.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/20/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieSummaryLabel: UILabel!
    @IBOutlet weak var movieReleaseDateLabel: UILabel!
    @IBOutlet weak var moviePriceLabel: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieRightsLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var clipboardView: UIView!
    
    var movie: Movie?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let screenHeight = UIScreen.main.bounds.height
    
    //This function sets the back button to white and all of the labels and images to blank or nothing when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        clipboardView.layer.cornerRadius = 10
        clipboardView.layer.shadowColor = UIColor.black.cgColor
        clipboardView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        clipboardView.layer.shadowOpacity = 1.0
        clipboardView.layer.shadowRadius = 30
        movieTitleLabel.text = ""
        movieReleaseDateLabel.text = ""
        moviePriceLabel.text = ""
        movieSummaryLabel.text = ""
        movieRightsLabel.text = ""
        clipboardView.alpha = 0
        movieImage.image = nil
    }
    
    //This function sets all of the labels and images when the view appears as the info comes thru the segue when the view appears each time
    override func viewDidAppear(_ animated: Bool) {
        self.activityIndicator.stopAnimating()
        movieTitleLabel.text = self.movie?.getName()
        movieSummaryLabel.text = self.movie?.getSummary()
        movieReleaseDateLabel.text = "Release Date: " + (self.movie?.getReleaseDate())!
        if let priceDefault = UserDefaults.standard.object(forKey: "isSeeingRentalPrice") as? Bool {
            if priceDefault == true && self.movie?.getRentalPrice() != nil {
                moviePriceLabel.text = "Rent: " + (self.movie?.getRentalPrice())!
            } else {
                moviePriceLabel.text = "Purchase: " + (self.movie?.getPrice())!
            }
        }
        movieRightsLabel.text = self.movie?.getRights()
        if let url = NSURL(string: (self.movie?.getImage())!) {
            if let data = NSData(contentsOf: url as URL) {
                movieImage.image = UIImage(data: data as Data)
            } else {
                movieImage.image = #imageLiteral(resourceName: "NoImagePhoto")
            }
        }
        clipboardView.alpha = 0
        print("Rights: " + (self.movie?.getRights())!)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userIsPanned))
        panRecognizer.minimumNumberOfTouches = 1
        view.addGestureRecognizer(panRecognizer)
    }
    
    //This function is called as the user is panning
    func userIsPanned(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        //recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
        //movieImage.alpha = (600 - abs(translation.y)) / 600
        //print("VELOCITY " + String(describing: velocity))
        //print(String(describing: translation.y))
        movieImage.alpha = (screenHeight - abs(translation.y)) / screenHeight
        let reverseAlpha = 1 - movieImage.alpha
//        movieTitleLabel.alpha = reverseAlpha
//        moviePriceLabel.alpha = reverseAlpha
//        movieReleaseDateLabel.alpha = reverseAlpha
        clipboardView.alpha = reverseAlpha
        /*if velocity.y > 0 {
            //print("Moving down")
            movieImage.alpha = (screenHeight - abs(translation.y)) / screenHeight
            print(movieImage.alpha)
        } else {
            //print("Moving up")
            movieImage.alpha = (screenHeight - abs(translation.y)) / screenHeight
            print(movieImage.alpha)
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //This functions links the user to a safari url specific to each movie upon clicking the link button
    @IBAction func linkButtonTapped(_ sender: Any) {
        let url = URL(string: (self.movie?.getLink())!)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(url)
        }
    }
    
}
