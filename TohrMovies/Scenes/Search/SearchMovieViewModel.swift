//
//  SearchMovieViewModel.swift
//  TohrMovies
//
//  Created by Renato Mateus on 07/03/21.
//

import Foundation
import RxSwift
import RxCocoa

public struct SearchMovieViewModelInputs {
    let movieRepository: MovieServiceProtocol
    let query: Driver<String>
}

public protocol SearchMovieViewModelOutputs{
    var movies: Driver<[Movie]> { get }
    var isFetching: Driver<Bool> { get }
    var info: Driver<String?> { get }
    var hasInfo: Bool { get }
    var numberOfMovies: Int { get }
    func viewModelItemForMovie(at index: Int) -> MovieCollectionItemViewModel?
    func viewModelDetailForMovie(at index: Int) -> MovieDetailViewModel?
}

public protocol SearchMovieViewModelType {
    init(_ inputs: SearchMovieViewModelInputs)
    var outputs: SearchMovieViewModelOutputs { get }
}

public final class SearchMovieViewModel: SearchMovieViewModelType, SearchMovieViewModelOutputs {
    private let inputs: SearchMovieViewModelInputs
    private let disposeBag = DisposeBag()
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _info = BehaviorRelay<String?>(value: nil)
    
    fileprivate enum UIMessages {
        static let searchMessage: String = "Search your favorite movies"
        static let notFound: String = "No results found for: "
        static let error: String = "Oops, there was an error when fetching data: \nPlease, check your connection and try again"
    }
    
    public init(_ inputs: SearchMovieViewModelInputs) {
        self.inputs = inputs
        inputs.query.throttle(.seconds(1)).distinctUntilChanged().drive(onNext: { [weak self] (queryString) in
            self?.searchMovie(query: queryString)
            if queryString.isEmpty {
                self?._movies.accept([])
                self?._info.accept(UIMessages.searchMessage)
            }
        }).disposed(by: disposeBag)
    }
    
    public var outputs: SearchMovieViewModelOutputs {
        return self
    }
    
    public var movies: Driver<[Movie]> {
        return _movies.asDriver()
    }
    
    public var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    public var info: Driver<String?> {
        return _info.asDriver()
    }
    
    public var hasInfo: Bool {
        return _info.value != nil
    }
    
    public var numberOfMovies: Int {
        return _movies.value.count
    }
    
    public func viewModelItemForMovie(at index: Int) -> MovieCollectionItemViewModel? {
        guard index < _movies.value.count else {
            return nil
        }
        return MovieCollectionItemViewModel(withMovie: _movies.value[index])
    }
    
    public func viewModelDetailForMovie(at index: Int) -> MovieDetailViewModel? {
        guard index < _movies.value.count else {
            return nil
        }
        let vmInput = MovieDetailViewModelInputs(movie: _movies.value[index], movieRepository: inputs.movieRepository)
        return MovieDetailViewModel(vmInput)
    }
    
    private func searchMovie(query: String?){
        guard let query  = query, !query.isEmpty else {
            _info.accept(UIMessages.searchMessage)
            return
        }
        
        _isFetching.accept(true)
        _movies.accept([])
        _info.accept(nil)
        
        inputs.movieRepository.searchMovie(query: query, successHandler: {[weak self] (response) in
            self?._isFetching.accept(false)
            if response.totalResults == 0 {
                self?._info.accept(UIMessages.notFound + "\(query)")
            }
            self?._movies.accept(Array(response.results.prefix(5)))
            
        }) {[weak self] (error) in
            self?._isFetching.accept(false)
            self?._info.accept(UIMessages.error)
        }
    }
    
    
    
    
}
