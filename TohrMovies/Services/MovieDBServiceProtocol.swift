//
//  MovieDBServiceProtocol.swift
//  TohrMovies
//
//  Created by Renato Mateus on 06/03/21.
//

import UIKit

protocol MovieServiceProtocol {
    
    func fetchMovieCollection(by collectionType: MDMovieCollection, successHandler: @escaping (_ response: MoviesResponse) -> Void, errorHandler: @escaping(_ error: Error) -> Void)
    
    func fetchMovie(id: Int, successHandler: @escaping (_ response: MovieDetail) -> Void, errorHandler: @escaping(_ error: Error) -> Void)
    
    func searchMovie(query: String, successHandler: @escaping (_ response: MoviesResponse) -> Void, errorHandler: @escaping(_ error: Error) -> Void)
}

public enum MDMovieCollection: String, CustomStringConvertible, CaseIterable {
    case upcoming
    case popular
    case topRated = "top_rated"
    
    public init?(index: Int) {
        switch index {
        case 0:
            self = .upcoming
        case 1:
            self = .popular
        case 2:
            self = .topRated
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .upcoming:
            return "Upcoming"
        case .popular:
            return "Popular"
        case .topRated:
            return "Top Rated"
        }
    }
}

public enum MDError: Error {
    case requestError(Error)
    case invalidResponse
    case serializationError
    case noData
}

