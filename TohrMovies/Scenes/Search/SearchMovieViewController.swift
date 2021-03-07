//
//  SearchMovieViewController.swift
//  TohrMovies
//
//  Created by Renato Mateus on 07/03/21.
//

import UIKit
import RxSwift
import RxCocoa

class SearchMovieViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var movieSearchViewModel: SearchMovieViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        tableView.backgroundColor = .yellow
        
        tableView.dataSource = self
        tableView.delegate = self
        setupNavigationBar()
        guard  let searchBar = self.navigationItem.searchController?.searchBar else {
            fatalError("wrong controller")
        }
        
        let vmInputs = SearchMovieViewModelInputs(movieRepository: MDRepository.shared,
                                                  query: searchBar.rx.text.orEmpty.asDriver())
        movieSearchViewModel = SearchMovieViewModel(vmInputs)
        
        movieSearchViewModel.outputs.movies
            .drive(onNext: {[unowned self] (_) in
                self.tableView.reloadSections(IndexSet(integersIn: 0...0), with: UITableView.RowAnimation.automatic)
            })
            .disposed(by: disposeBag)
        
        movieSearchViewModel.outputs.isFetching
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        movieSearchViewModel.outputs.info
            .drive(onNext: {[unowned self] (info) in
                self.infoLabel.isHidden = !self.movieSearchViewModel.outputs.hasInfo
                self.infoLabel.text = info
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned searchBar] in
                searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned searchBar] in
                searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        setupTableView()
    }
    
    private func setupNavigationBar() {
       
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.definesPresentationContext = true
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController?.searchBar.sizeToFit()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.registerReusableCell(MovieTableViewCell.self)
    }
    
}


extension SearchMovieViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieSearchViewModel.outputs.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.backgroundColor = Styles.lightYellow
        cell.configure(with: movieSearchViewModel.outputs.viewModelItemForMovie(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vm = movieSearchViewModel.outputs.viewModelDetailForMovie(at: indexPath.row), let vcDetail = MovieDetailViewController.createMovieDetailController(detailViewModel: vm){
            self.navigationController?.pushViewController(vcDetail, animated: true)
        }
    }
}
