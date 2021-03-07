//
//  MovieTableViewCell.swift
//  TohrMovies
//
//  Created by Renato Mateus on 06/03/21.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    
    func configure(with viewModel: MovieCollectionItemViewModel?) {
        titleLabel.text = viewModel?.title ?? ""
        overviewLabel.text = viewModel?.overview ?? ""
        if let posterURL = viewModel?.posterURL {
            posterImageView.setImage(fromURL: posterURL)
        } else {
            posterImageView.image = nil
        }
    }
}

extension MovieTableViewCell: NibLoadableView { }

extension MovieTableViewCell: ReusableView { }

