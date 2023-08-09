//
//  BookRouter.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/08/08.
//

import Foundation
import Alamofire

enum BookRouter{
    enum BookRouterError:Error{
        case queryEncodingError
    }
    static let baseURL = "https://dapi.kakao.com/v3/search/book"
    static let maxPage = 50
    case search(query:String,page:Int = 1,size:Int = 10)
    var headers:HTTPHeaders{
        switch self{
        case .search:
            return HTTPHeaders(["Authorization":"KakaoAK \(API_Key.kakaoRest)"])
        }
    }
    var method:HTTPMethod{
        switch self{
        case .search:
            return .get
        }
    }
    private var datapreprocess:(String?,HTTPMethod,HTTPHeaders){
        switch self{
        case .search(let query,let page,let size):
            if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                return ("\(Self.baseURL)?query=\(encodedQuery)&page=\(page)&size=\(size)",method,headers)
            }else{
                return (nil,method,headers)
            }
        }
    }
    func action(completion:@escaping (AFDataResponse<Any>) -> Void) throws{
        let (str,method,headers) = datapreprocess
        guard let str else {
            throw BookRouterError.queryEncodingError
        }
        AF.request(str,method:method,headers:headers)
            .validate(statusCode:200...500)
            .responseJSON(completionHandler: completion)
    }
}
