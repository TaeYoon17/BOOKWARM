//
//  SearchingVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/04.
//

import UIKit
import SnapKit
import SwiftyJSON
import RealmSwift
final class SearchingVC: UIViewController{
    var collectionView: UICollectionView!
    var diffableDataSource: UICollectionViewDiffableDataSource<Section,Item>!
    weak var searchBar: UISearchBar!
    weak var mainVC: SearchMainVC!
    var nowStatus = Section.searching{
        didSet{ dataSourceUpdating() }
    }
    var searchText = ""
    var isEnded = false
    var requestedPage = 0
    var bookListColor:[UIColor] = []
    var bookmodel: [Book] = []
    var realm: Realm!
    let repository = TableRepository<BookTable>()
    var tasks: Results<BookTable>!
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        self.tasks = realm.objects(BookTable.self).sorted(byKeyPath: "title",ascending: false)
        configureCollectionView()
        configureDataSource()
    }
    private func configureDataSource(){
        let headerRegistration = UICollectionView.SupplementaryRegistration<TempHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) {[weak self] supplementaryView, elementKind, indexPath in
            guard let section = Section(rawValue: indexPath.section) else {return}
            switch section{
            case .result: break
            case .searching:
                supplementaryView.titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
                supplementaryView.titleLabel.text = section.koreanDescription
                var config = UIButton.Configuration.plain()
                config.attributedTitle = .init("지우기",attributes: .init([
                    NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline)
                ]))
//                configuration = config
                let button = UIButton(configuration: config,primaryAction: .init(handler: { [weak self] _ in
                    let alert = UIAlertController(title: nil, message: nil,preferredStyle: .actionSheet)
                    alert.addAction(.init(title: "최근 검색 지우기", style: .default))
                    alert.addAction(.init(title: "취소", style: .cancel))
                    self?.present(alert,animated: true)
                }))
                supplementaryView.trailingBtn = button
            }
        }
        self.diffableDataSource = UICollectionViewDiffableDataSource<Section,Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {return UICollectionViewCell()}
            switch item{
            case .result(item: let item,color: let color):
                cell.bgColor = color
                cell.configureByBook(title: item.title, thumbnailURL: item.thumbnailURL, price: item.price)
            case .recent(item: let item,color: let color):
                cell.bgColor = color
                cell.configureByTable(title: item.title, thumbnailPath: item.isbn, price: item.price)
            }
            return cell
        })
        //MARK: -- 헤더를 넣을 수도..?
        self.diffableDataSource.supplementaryViewProvider = { c,elementKind,indexPath -> UICollectionReusableView? in
            guard let section = Section(rawValue: indexPath.section) else {return nil}
            switch elementKind{
            case UICollectionView.elementKindSectionHeader:
                switch section{
                case .searching:
                    return c.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
                case .result: return nil
                }
            default: return nil
            }
        }
        dataSourceUpdating()
    }
}

extension SearchingVC{
    func searchQuery(){
        print(#function)
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
                        self?.nowStatus = .result
                        self?.dataSourceUpdating()
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
