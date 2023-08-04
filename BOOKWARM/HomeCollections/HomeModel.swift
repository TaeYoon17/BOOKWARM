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
    private var movieModel = MovieInfo().movie.map{($0,UIColor.random)}
    private var searchedMovies:[(Movie,UIColor)] = [].map{($0,UIColor.random)}
    private var indexList:[Int] = []
    var infoType:HomeInfoType{
        didSet{
            switch infoType {
            case .Search:
                indexList = []
            case .Read:
                break
            }
        }
    }
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
        let enus = self.movieModel.enumerated().filter{ $0.element.0.title.contains(searchText)}
        self.indexList = enus.map{ $0.offset }
        self.searchedMovies = enus.map{$0.element}
    }
    //어떻게 하냐고...
    func setList(index: Int,movie:Movie){
        switch infoType {
        case .Search:
            self.searchedMovies[index].0 = movie
            let rawIndex = indexList[index]
            self.movieModel[rawIndex].0 = movie
        case .Read:
            self.movieModel[index].0 = movie
        }
    }
}
