//
//  MovieModel.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import Foundation
struct MovieModel{
    let title:String
    let releaseDate: String
    let runtime: Int
    var overview: String
    var rate: Double
}

struct Movie{
    let title:String
    let releaseDate: String
    let runtime: Int
    var overview: String
    var rate: Double
    var like:Bool
    init(_ model:MovieModel){
        self.title = model.title
        self.releaseDate = model.releaseDate
        self.runtime = model.runtime
        self.overview = model.overview
        self.rate = model.rate
        self.like = false
    }
}
