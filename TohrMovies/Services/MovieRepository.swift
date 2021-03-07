//
//  MovieRepository.swift
//  TohrMovies
//
//  Created by Renato Mateus on 06/03/21.
//

import Alamofire

class MDRepository: MovieServiceProtocol {

    public static let shared = MDRepository()
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    fileprivate func fetchCodableEntity<T: Codable>(from request: MDRequest, successHandler: @escaping (T) -> Void, errorHandler: @escaping (Error) -> Void) {
        
        AF.request(request)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let rsp = try self.jsonDecoder.decode(T.self, from: data)
                        DispatchQueue.main.async {
                            successHandler(rsp)
                        }
                    } catch {
                        print(error)
                        DispatchQueue.main.async {
                            errorHandler(MDError.serializationError)
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        errorHandler(MDError.requestError(error))
                    }
                }
        }
    }
    
    func configureCache() {
        let aURLCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024, // 20 MB
            diskCapacity: 100 * 1024 * 1024,  // 100 MB
            diskPath: "org.tohr.movies"
        )
        URLCache.shared = aURLCache
    }
    
    func fetchMovieCollection(by collectionType: MDMovieCollection, successHandler: @escaping (MoviesResponse) -> Void, errorHandler: @escaping (Error) -> Void) {
        fetchCodableEntity(from: MDRequest.collection(collectionType), successHandler: successHandler, errorHandler: errorHandler)
    }
    
    func fetchMovie(id: Int, successHandler: @escaping (MovieDetail) -> Void, errorHandler: @escaping (Error) -> Void) {
        fetchCodableEntity(from: MDRequest.fetchMovieByID(id), successHandler: successHandler, errorHandler: errorHandler)
    }
    
    func searchMovie(query: String, successHandler: @escaping (MoviesResponse) -> Void, errorHandler: @escaping (Error) -> Void) {
        fetchCodableEntity(from: MDRequest.searchByText(query), successHandler: successHandler, errorHandler: errorHandler)
    }
}
