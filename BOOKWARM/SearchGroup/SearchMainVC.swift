//
//  SearchVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit
import SwiftyJSON
import Kingfisher
class SearchMainVC: UIViewController{
    static let identifier = "SearchVC"
    enum Section:Int,CaseIterable{ case keyword,result }
    var collectionView: UICollectionView!
    var bookmodel: [Book] = []{
        didSet{ collectionView.reloadData() }
    }
//  ViewController State Data
    var searchText = ""
    var requestedPage = 0
    var isEnded = false
    var bookListColor:[UIColor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureCollectionView()
    }
    @objc func closeBtnTapped(){ self.dismiss(animated: true) }
    
    func fetchList(){
        do{
            let newPage = requestedPage + 1
            try BookRouter.search(query: self.searchText,page: newPage).action {[weak self] response in
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    if let arrayValue = json["documents"].array{
                        self?.isEnded = json["meta"]["is_end"].boolValue
                        print(self?.isEnded)
                        let list = Book.getBookLists(jsonList: arrayValue)
                        self?.bookmodel.append(contentsOf: list)
                        self?.bookListColor.append(contentsOf: list.map{_ in UIColor.random})
                        self?.requestedPage = newPage
                    }
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

extension SearchMainVC: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - 40{
            fetchList()
        }
    }
}


extension SearchMainVC: UISearchBarDelegate{
    func configureSearchBar(){
        let searchController = UISearchController(searchResultsController: SearchingVC())
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "도서를 검색하세요"
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
//        searchBar.placeholder = "검색할 책을 입력하세요"; searchBar.text = searchText
//        searchBar.delegate = self
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,text != searchText else {return}
        self.searchText = text; self.requestedPage = 0
        self.bookListColor.removeAll();self.bookmodel.removeAll()
        self.fetchList()
        searchBar.resignFirstResponder()
    }
}
extension UIAlertController{
    convenience init(title: String?,message:String?,cancelMessage:String? = nil) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addAction(.init(title: cancelMessage ?? "취소", style: .cancel))
    }
}
extension HomeCollectionViewCell{
    func searchVC_Configure(title:String,thumbnailURL:String,price:Int){
        self.likeBtn.isHidden = true
        self.titleLabel.text = title
        self.titleLabel.font = .boldSystemFont(ofSize: 15)
        self.titleLabel.numberOfLines = 2
        self.titleLabel.adjustsFontSizeToFitWidth = false
        self.scoreLabel.text = "\(price)원"
        self.scoreLabel.font = .systemFont(ofSize: 12)
        self.scoreLabel.numberOfLines = 0
        self.scoreLabel.textAlignment = .left
        self.posterImgView.kf.setImage(with: URL(string: thumbnailURL))
        self.posterImgView.contentMode = .scaleAspectFill
    }
}
extension Book{
    static func getBookLists(jsonList: [JSON])->[Self]{
        return jsonList.map{ json in
            let thumbnailURL = json["thumbnail"].stringValue
            let linkURL = json["url"].stringValue
            let authors = json["authors"].arrayValue.map{$0.stringValue}
            let contents = json["contents"].stringValue
            let isbn = json["isbn"].stringValue
            let title = json["title"].stringValue
            let translators: [String] = json["translators"].arrayValue.map{$0.stringValue}
            let price = json["price"].intValue; let sale_price = json["sale_price"].intValue
            let publisher = json["publisher"].stringValue
            let status = json["status"].stringValue
            return Book(authors: authors, conetnts: contents, datetime: Date.now, isbn: isbn, price: price, publisher: publisher, slae_price: sale_price, status: status, thumbnailURL:  thumbnailURL, title: title, translators: translators, linkURL: linkURL)
        }
    }
}
// MARK: -- Legacy dataFlowLayout
//let layout = {
//    let layout = UICollectionViewFlowLayout()
//    let spacing:CGFloat = 20; let groupItemsCount = 2;
//    let cellWidth: Int = (Int(UIScreen.main.bounds.width) -
//                          Int(spacing) * (groupItemsCount + 1)) / groupItemsCount
//    guard cellWidth > 0  else { fatalError("이건 아니지") }
//    layout.itemSize = .init(width: cellWidth,height: cellWidth)
//    layout.sectionInset = .init(top: spacing, left: spacing,
//                                bottom: spacing, right: spacing)
//    // 그룹간의 간격
//    layout.minimumLineSpacing = spacing
//    // 아이템간의 간격
//    layout.minimumInteritemSpacing = spacing
//    return layout
//}()
