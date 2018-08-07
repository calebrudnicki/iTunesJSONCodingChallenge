//
//  ViewControllerTableViewCell.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 3/20/17.
//  Copyright © 2017 Caleb Rudnicki. All rights reserved.
//

import UIKit
import PureLayout
import Kingfisher

protocol MovieTableViewCellDelegate {
    func movieTableViewCellDidAddMovieToFavorites(movie: Movie)
}

class MovieTableViewCell: UITableViewCell {
    
    var screenWidth: CGFloat { return UIScreen.main.bounds.width }
    var screenHeight: CGFloat { return UIScreen.main.bounds.height }
    
    var delegate: MovieTableViewCellDelegate?
    var movie: Movie?

    let posterView = UIImageView()
    let rankLabel = UILabel()
    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let releaseDateLabel = BodyLabel()
    let button = RoundButton()
    var cardView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        var margins = layoutMargins
        margins.left = 12
        margins.top = 22
        margins.right = 12
        margins.bottom = 22
        contentView.layoutMargins = margins
        
        cardView.backgroundColor = UIColor.lightGray
        cardView.layer.cornerRadius = 5
        cardView.layer.borderColor = UIColor.darkGray.cgColor
        cardView.layer.borderWidth = 2
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.shadowRadius = 5
        cardView.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        rankLabel.textColor = UIColor.black
        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        button.backgroundColor = .red
        
        let buttonTap = UITapGestureRecognizer(target: self, action: #selector(self.buttonTap(_:)))
        buttonTap.delegate = self
        button.addGestureRecognizer(buttonTap)
        
        cardView.addSubview(posterView)
        cardView.addSubview(rankLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(releaseDateLabel)
        cardView.addSubview(button)
        
        posterView.autoPinEdge(toSuperviewEdge: .top)
        posterView.autoPinEdge(toSuperviewEdge: .leading)
        posterView.autoPinEdge(toSuperviewEdge: .trailing)
        
        rankLabel.autoPinEdge(.top, to: .bottom, of: posterView, withOffset: 8)
        rankLabel.autoPinEdge(toSuperviewMargin: .leading)
        rankLabel.autoPinEdge(.bottom, to: .top, of: releaseDateLabel, withOffset: -8)
        
        titleLabel.autoPinEdge(.top, to: .bottom, of: posterView, withOffset: 8)
        titleLabel.autoPinEdge(.leading, to: .trailing, of: rankLabel, withOffset: 8)
        titleLabel.autoPinEdge(toSuperviewMargin: .trailing)
        titleLabel.autoPinEdge(.bottom, to: .top, of: releaseDateLabel, withOffset: -8)

        releaseDateLabel.autoPinEdge(toSuperviewMargin: .leading)
        releaseDateLabel.autoPinEdge(toSuperviewMargin: .trailing)
        
        button.autoPinEdge(.top, to: .bottom, of: releaseDateLabel, withOffset: 8)
        button.autoPinEdges(toSuperviewMarginsExcludingEdge: .top)
        
        contentView.addSubview(cardView)
        cardView.autoPinEdgesToSuperviewMargins()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        posterView.autoSetDimensions(to: CGSize(width: cardView.frame.width, height: screenHeight * 0.2))
    }
    
    func buttonTap(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.movieTableViewCellDidAddMovieToFavorites(movie: movie!)
    }
    
    func display(rank: Int, movie: Movie) {
        if let url = NSURL(string: movie.image!) {
            let resource = ImageResource(downloadURL: url as URL, cacheKey: movie.name)
            self.posterView.kf.setImage(with: resource)
        }
        self.movie = movie
        self.rankLabel.text = "#\(rank)"
        self.titleLabel.text = movie.name
        self.releaseDateLabel.text = movie.releaseDate
        self.button.titleLabel?.text = "MY BUTTON"
    }

}

@IBDesignable class RoundButton: UIButton {

    @IBInspectable var borderColor: UIColor = UIColor.blue {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0.5 * bounds.size.height
        clipsToBounds = true
    }
}
