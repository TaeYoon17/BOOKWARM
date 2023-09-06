//
//  SearchingVC+ViewModel.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/05.
//

import UIKit
extension SearchingVC{
    enum Section:Int{
        case searching,result
        var koreanDescription:String{
            switch self{
            case .result: return "검색 결과"
            case .searching: return "최근 검색 값"
            }
        }
    }
    enum Item:Hashable{
        case result(item:Book,color:UIColor?)
        case recent(item:BookTable,color:UIColor?)
    }
}
