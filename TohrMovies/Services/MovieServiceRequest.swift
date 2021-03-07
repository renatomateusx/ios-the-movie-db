//
//  MovieServiceRequest.swift
//  TohrMovies
//
//  Created by Renato Mateus on 06/03/21.
//


import Alamofire

public enum MDRequest: URLRequestConvertible {
    
    enum Constants {
        static let baseURLPath = "https://api.themoviedb.org/3"
        static let apiKey =  "2e73a1c40f30365f00d2176b4c96f1af" //ProcessInfo.processInfo.environment["TMDBAPIKEY"] ?? ""
    }
    
    case collection(MDMovieCollection)
    case fetchMovieByID(Int)
    case searchByText(String)
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .collection(let type):
            switch type {
            case .upcoming:
                return "/movie/upcoming"
            case .popular:
                return "/movie/popular"
            case .topRated:
                return "/movie/top_rated"
            }
        case .fetchMovieByID(let id):
            return "/movie/\(id)"
        case .searchByText:
            return "/search/movie"
        }
        
    }
    
    var parameters: [String: Any] {
        var params = ["api_key": Constants.apiKey]
        switch self {
        case .collection:
            break
        case .fetchMovieByID:
            params["append_to_response"] = "videos,credits"
        case .searchByText(let q):
            params["append_to_response"] = "videos,credits"
            params["language"] = "en-US"
            params["include_adult"] = "false"
            params["region"] = "US"
            params["query"] = q
        }
        return params
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try Constants.baseURLPath.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
}

