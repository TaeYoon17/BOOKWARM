//
//  HomeLegacyCode.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/08/04.
//

import Foundation
import UIKit
//    class ViewModel{
//        var collectionView: UICollectionView
//        public private(set) var infos = MovieInfo()
//        public private(set) var searchedMovies:[Movie] = []{
//            didSet{
//                print(searchedMovies)
//                self.collectionView.reloadData()
//            }
//        }
//        var searchedIdx:[Int] = []
//        lazy var datasBgColor: [UIColor] = { (0..<infos.movie.count).map{_ in .random} }()
//        var searchedBgColors: [UIColor] = []
//        var viewType:ViewType
//        init(viewType: ViewType,collectionView: UICollectionView){
//            self.viewType = viewType
//            self.collectionView = collectionView
//        }
//        func getMovie(idx:Int)->Movie?{
//            switch viewType{
//            case .Read:
//                return self.infos.movie[safe: idx]
//            case .Search:
//                return self.searchedMovies[safe: idx]
//            }
//        }
//        func getColor(idx:Int)-> UIColor?{
//            switch viewType{
//            case .Read:
//                return self.datasBgColor[safe: idx]
//            case .Search:
//                return self.searchedBgColors[safe: idx]
//            }
//        }
//        var count:Int{
//            switch viewType{
//            case .Read: return infos.movie.count
//            case .Search: return searchedMovies.count
//            }
//        }
//        func setSearchList(searchText:String){
//            self.searchedIdx = self.infos.movie.enumerated()
//                .filter{$0.1.title.contains(searchText)}
//                .map{$0.0}
//            self.searchedMovies = self.searchedIdx.map{self.infos.movie[$0]}
//            self.searchedBgColors = self.searchedIdx.map{self.datasBgColor[$0]}
//        }
//    }
