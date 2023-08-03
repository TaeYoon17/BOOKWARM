//
//  HomeModel.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/08/04.
//

import Foundation
import UIKit
class HomeModel{
    enum HomeInfoType{
        case Search
        case Read
    }
    let movies = MovieInfo().movie
    private lazy var moviesColor = movies.map{_ in UIColor.random}
    var movieModel = MovieInfo().movie.map{($0,UIColor.random)}
    private var searchedMovies:[(Movie,UIColor)] = [].map{($0,UIColor.random)}
    var infoType:HomeInfoType
    init(infoType: HomeInfoType){
        self.infoType = infoType
    }
    func getMovieModel(idx:Int)->(Movie,UIColor)?{
        switch infoType{
        case .Read:
            guard let movie = movieModel[safe: idx] else{
                return nil
            }
            return movie
        case .Search:
            guard let movie = searchedMovies[safe: idx] else{
                return nil
            }
            return movie
        }
    }
    var count:Int{
        switch infoType{
        case .Read: return movies.count
        case .Search: return searchedMovies.count
        }
    }
    func setSearchList(searchText:String){
        guard infoType == .Search else {return}
        self.searchedMovies = self.movieModel.filter { (movie,color) in
            movie.title.contains(searchText)
        }
    }
}
