//
//  MovieCollectionViewConrollerViewController.swift
//  TohrMovies
//
//  Created by Renato Mateus on 05/03/21.
//

import UIKit
import RxCocoa
import RxSwift

class MovieCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorInfoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var categoryCollectionSegControl: UISegmentedControl!
    
    var movieCollectionViewModel: MovieCollectionViewModel!
    let disposeBag = DisposeBag()
    
    fileprivate enum UIContants {
        static let margin: CGFloat = 15.0
        static let nbrOfItemsInARow: CGFloat = 2.0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSegmentedController()
        
        let collectionTypeSelected = categoryCollectionSegControl.rx.selectedSegmentIndex
            .map { MDMovieCollection(index: $0) ?? .popular }
            .asDriver(onErrorJustReturn: .popular)
        
        let mvInputs = MovieCollectionViewModelInputs(movieRepository: MDRepository.shared, collectionTypeSelected: collectionTypeSelected)
        
        movieCollectionViewModel = MovieCollectionViewModel(mvInputs)
        
        movieCollectionViewModel.outputs.movies.drive(
            onNext: {[unowned self] (_) in
                self.collectionView.reloadSections(IndexSet(integersIn: 0...0))}).disposed(by: disposeBag)
        
        movieCollectionViewModel.outputs.error.drive(onNext: {[unowned self] (error) in self.errorInfoLabel.isHidden = !self.movieCollectionViewModel.outputs.hasError
            self.errorInfoLabel.text = error
        }).disposed(by: disposeBag)
    }
    
    func setupCollectionView(){
        view.backgroundColor = .yellow
        collectionView.backgroundColor = .yellow
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerReusableCell(MovieCollectionViewCell.self)
    }
    func setupSegmentedController(){
        self.categoryCollectionSegControl.removeAllSegments()
        var index = 0
        for collectionType in MDMovieCollection.allCases {
            self.categoryCollectionSegControl.insertSegment(withTitle: collectionType.description, at: index, animated: false)
            index += 1
        }
        self.categoryCollectionSegControl.selectedSegmentIndex = 0
    }

}

extension MovieCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieCollectionViewModel.outputs.numberOfMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MovieCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: movieCollectionViewModel.outputs.viewModelItemForMovie(at: indexPath.row))
        return cell
    }
}

extension MovieCollectionViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let vm = movieCollectionViewModel.outputs.viewModelDetailForMovie(at: indexPath.row), let vcDetail = MovieDetailViewController.createMovieDetailController(detailViewModel: vm) {
            self.navigationController?.pushViewController(vcDetail, animated: true)
        }
    }
}

extension MovieCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let cellWidth = (screenSize.width - (UIContants.margin * (UIContants.nbrOfItemsInARow + 1))) / UIContants.nbrOfItemsInARow
        let cellHeight = cellWidth * ImageSize.heightPosterRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.self.init(top: UIContants.margin, left: UIContants.margin, bottom: UIContants.margin, right: UIContants.margin)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIContants.margin
    }
    
}
