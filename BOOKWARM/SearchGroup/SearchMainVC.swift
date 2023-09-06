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
    enum Section:Int,CaseIterable{
        case keyword,result
        enum Item:Hashable{
            case keyword(category: BookCategory)
            case result(book: Book)
        }
        var koreanDescription:String{
            switch self{
            case .keyword: return "추천 검색어"
            case .result: return "검색 결과"
            }
        }
    }
    var collectionView: UICollectionView!
    var diffableDataSource: UICollectionViewDiffableDataSource<Section,Section.Item>!
    var categoryModel = BookCategory.allCases
    var bookmodel: [Book] = []
//  ViewController State Data
    var searchText = ""
    var requestedPage = 0
    var isEnded = false
    var bookListColor:[UIColor] = []
    var searchingVC = SearchingVC()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureCollectionView()
        configureDataSource()
    }
    @objc func closeBtnTapped(){ self.dismiss(animated: true) }
    
    func configureDataSource(){
        let keywordHeaderRegistration = UICollectionView.SupplementaryRegistration<TempHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            guard let section = Section(rawValue: indexPath.section) else {return}
            supplementaryView.titleLabel.text = section.koreanDescription
            supplementaryView.titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        }
        let keywordCellRegistration = UICollectionView.CellRegistration<KeywordCell,Section.Item> { cell, indexPath, itemIdentifier in
            switch itemIdentifier{
            case .keyword(category: let category):
                cell.imageView.image = UIImage(named: category.rawValue)
                cell.infoLabel.text = BookCategory.korean[category]
            default: fatalError("이럴 수가 없음..!")
            }
        }
        let resultHeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            guard let section = Section(rawValue: indexPath.section) else {return}
            var config = supplementaryView.defaultContentConfiguration()
            config.text = section.koreanDescription
        }
        let resultcCellRegistration = UICollectionView.CellRegistration<HomeCollectionViewCell,Section.Item>{[weak self] cell, indexPath, item in
            switch item{
            case .result(book: let book):
                cell.bgColor = self?.bookListColor[indexPath.row]
                cell.configureByBook(title: book.title, thumbnailURL: book.thumbnailURL, price: book.price)
            default: fatalError("이럴 수가 없음..!")
            }
        }
        self.diffableDataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
                return collectionView.dequeueConfiguredReusableCell(using: keywordCellRegistration, for: indexPath, item: itemIdentifier)
        })
        self.diffableDataSource.supplementaryViewProvider = { c,elementKind,indexPath -> UICollectionReusableView? in
            guard let section = Section(rawValue: indexPath.section) else {return nil}
            switch elementKind{
            case UICollectionView.elementKindSectionHeader:
                switch section{
                case .keyword:
                    let cell = c.dequeueConfiguredReusableSupplementary(using: keywordHeaderRegistration, for: indexPath)
                    DispatchQueue.main.async{
                        cell.layer.cornerRadius = 20
                    }
                    return cell
                case .result:
                    return c.dequeueConfiguredReusableSupplementary(using: resultHeaderRegistration, for: indexPath)
                }
            default: return nil
            }
        }
        dataSourceToKeyword()
    }
    func dataSourceToKeyword(){
        var snapshot = NSDiffableDataSourceSnapshot<Section,Section.Item>()
        snapshot.appendSections([.keyword])
        snapshot.appendItems(categoryModel.map{.keyword(category: $0)},toSection: .keyword)
        diffableDataSource.apply(snapshot,animatingDifferences: true)
    }
    func dataSourceToResult(){
        var snapshot = NSDiffableDataSourceSnapshot<Section,Section.Item>()
        snapshot.appendSections([.result])
        snapshot.appendItems(bookmodel.map{.result(book: $0)},toSection: .result)
        diffableDataSource.apply(snapshot,animatingDifferences: true)
    }
}


//MARK: -- 데이터 가져오는 코드
extension SearchMainVC{
    func fetchList(){
        do{
            let newPage = requestedPage + 1
            try BookRouter.search(query: self.searchText,page: newPage).action {[weak self] response in
                switch response.result{
                case .success(let data):
                    let json = JSON(data)
                    if let arrayValue = json["documents"].array{
                        self?.isEnded = json["meta"]["is_end"].boolValue
//                        print(self?.isEnded)
                        let list = Book.getBookLists(jsonList: arrayValue)
                        self?.bookmodel.append(contentsOf: list)
                        self?.bookListColor.append(contentsOf: list.map{_ in UIColor.random})
                        self?.requestedPage = newPage
                        DispatchQueue.main.async {
                            self?.searchingVC.nowStatus = .searching
                            self?.searchingVC.bookListColor = self!.bookListColor
                            self?.searchingVC.bookmodel = self!.bookmodel
//                            self?.searchingVC.dataSourceToResult()
                        }
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

extension SearchMainVC:UISearchControllerDelegate,UISearchBarDelegate{
    func configureSearchBar(){
        let searchController = UISearchController(searchResultsController: searchingVC)
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "도서를 검색하세요"
        searchController.obscuresBackgroundDuringPresentation = false
        searchingVC.searchBar = searchController.searchBar
        searchingVC.mainVC = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,text != searchText else {return}
        print(text)
        self.searchingVC.searchText = text;self.searchingVC.requestedPage = 0
        self.searchingVC.bookListColor.removeAll();self.bookmodel.removeAll()
        self.searchingVC.searchQuery()
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(#function)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.searchingVC.nowStatus != .searching{
            self.searchingVC.nowStatus = .searching
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
extension UIAlertController{
    convenience init(title: String?,message:String?,cancelMessage:String? = nil) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addAction(.init(title: cancelMessage ?? "취소", style: .cancel))
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
//            return Book(title: title, isbn: contents, price: Date.now, contents: isbn, authors: price, datetime: publisher, publisher: publisher, salePrice: sale_price, status:  thumbnailURL, thumbnailURL: title, translators: translators, linkURL: linkURL)
            return Book(title: title, isbn: isbn, price: price, contents: contents, authors: authors, datetime: Date(), publisher: publisher, salePrice: sale_price, status: status, thumbnailURL: thumbnailURL, translators: translators, linkURL: linkURL)
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
