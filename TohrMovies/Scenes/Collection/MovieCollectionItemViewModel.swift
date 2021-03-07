//
//  MovieCollectionItemViewModel.swift
//  TohrMovies
//
//  Created by Renato Mateus on 05/03/21.
//

import RxSwift

public struct MovieCollectionItemViewModel {
    private let disposeBag = DisposeBag()
    private let movie: Movie
    
    private static let dateFormatter: DateFormatter = {
        $0.dateFormat = "yyyy"
        return $0
    }(DateFormatter())
    
    init(withMovie movie: Movie){
        self.movie = movie
    }
    var posterURL: URL? {
        if let path = movie.posterPath {
            return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
        }
        return nil
    }
    
    var title: String? {
        return movie.title
    }
    var overview: String? {
        return movie.overview
    }
}
