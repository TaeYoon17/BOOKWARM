//
//  SearchVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit
import SwiftyJSON
class SearchVC: UIViewController{
    static let identifier = "SearchVC"
    let searchBar = UISearchBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "검색화면"
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "xmark"), style: .plain, target: self, action: #selector(Self.closeBtnTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationItem.titleView = searchBar
        searchBar.placeholder = "검색할 책을 입력하세요"
        searchBar.delegate = self
    }
    @objc func closeBtnTapped(){
        self.dismiss(animated: true)
    }
}

extension SearchVC: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {return}
        print(text)
        do{
            try BookRouter.search(query: text).action { response in
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    print(json)
                case .failure(let err):
                    print(err)
                }
            }
        }catch(let err){
            print(err)
            present(UIAlertController(title: "서버 값 가져오기 실패", message: nil, cancelMessage: nil),animated: true)
        }
    }
}
extension UIAlertController{
    convenience init(title: String?,message:String?,cancelMessage:String? = nil) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addAction(.init(title: cancelMessage ?? "취소", style: .cancel))
    }
}
