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
class SearchingVC: UIViewController{
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
    var nowStatus = Section.searching{
        didSet{ dataSourceUpdating() }
    }
    var collectionView: UICollectionView!
    var diffableDataSource: UICollectionViewDiffableDataSource<Section,Item>!
    weak var searchBar: UISearchBar!
    var bookListColor:[UIColor] = []
    var bookmodel: [Book] = []
    var searchText = ""
    var requestedPage = 0
    var isEnded = false
    var realm: Realm!
    var tasks: Results<BookTable>!
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        self.tasks = realm.objects(BookTable.self).sorted(byKeyPath: "title",ascending: false)
        configureCollectionView()
        configureDataSource()
    }
    func configureDataSource(){
        //MARK:-- 헤더를 넣을 수도..?
        let headerRegistration = UICollectionView.SupplementaryRegistration<TempHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            guard let section = Section(rawValue: indexPath.section) else {return}
            switch section{
            case .result: break
            case .searching:
                supplementaryView.titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
                supplementaryView.titleLabel.text = section.koreanDescription
            }
        }
        let resultcCellRegistration = UICollectionView.CellRegistration<HomeCollectionViewCell,Item>{[weak self] cell, indexPath, item in
            switch item{
            case .result(item: let item,color: let color):
                cell.bgColor = color
                cell.searchVC_Configure(title: item.title, thumbnailURL: item.thumbnailURL, price: item.price)
            case .recent(item: let item, color: let color):
                cell.bgColor = color
                cell.searchVC_Configure(title: item.title, thumbnailURL: item.thumbnailURL, price: item.price)
            }
        }
        self.diffableDataSource = UICollectionViewDiffableDataSource<Section,Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {return UICollectionViewCell()}
            switch item{
            case .result(item: let item,color: let color):
                cell.bgColor = color
                cell.searchVC_Configure(title: item.title, thumbnailURL: item.thumbnailURL, price: item.price)
            case .recent(item: let item,color: let color):
                cell.bgColor = color
                cell.searchVC_Configure(title: item.title, thumbnailURL: item.thumbnailURL, price: item.price)
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
                    let cell = c.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
                    DispatchQueue.main.async{
                        cell.layer.cornerRadius = 20
                    }
                    return cell
                case .result: return nil
                }
            default: return nil
            }
        }
        dataSourceUpdating()
    }
    
}
extension SearchingVC{
    func dataSourceUpdating(){
        func dataSourceToSearching(){
            DispatchQueue.main.async {
                    let items:[Item] = self.tasks.map{.recent(item: $0, color: .random)}
                    var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                    self.collectionView.collectionViewLayout = self.compositionalLayout
                    snapshot.appendSections([.searching])
                    snapshot.appendItems(items,toSection: .searching)
                    self.diffableDataSource.apply(snapshot,animatingDifferences: true)
            }
        }
        func dataSourceToResult(){
            DispatchQueue.global().async {
                let items:[Item] = zip(self.bookmodel, self.bookListColor).map{.result(item:$0,color:$1)}
                DispatchQueue.main.async {
                    var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                    snapshot.appendSections([.result])
                    snapshot.appendItems(items,toSection: .result)
                    self.collectionView.collectionViewLayout = self.compositionalLayout
                    self.diffableDataSource.apply(snapshot,animatingDifferences: true)
                }
            }
        }
        switch self.nowStatus{
        case .result:
            dataSourceToResult()
        case .searching:
            dataSourceToSearching()
        }
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
extension SearchingVC:UICollectionViewDelegate,UIScrollViewDelegate,UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            print(#function,indexPath.row,self.bookmodel.count)
            //            if indexPath.row > self.bookmodel.count - 5, requestedPage < BookRouter.maxPage,!self.isEnded{
            //                //여기서 request 로직 수행
            //                self.fetchList()
            //            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let canScroll = scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - 40
        if canScroll && nowStatus == .result{ searchQuery() }
        searchBar.endEditing(true)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {return}
        switch item{
        case let .result(item: book, color: _):
            let realm = try! Realm()
            let task = BookTable(book: book)
            try! realm.write{
                realm.add(task)
                print(task)
                print("Real Add Succeed")
            }
        default: break
        }
    }
    
    
    func configureCollectionView(){
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        self.collectionView.register(.init(nibName: HomeCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        self.collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewListCell.self))
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.delegate = self
    }
    var compositionalLayout: UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { index, environment in
            guard let sectionType = Section(rawValue: index) else {fatalError("이건 안되용~")}
            let groupHeightDimension: NSCollectionLayoutDimension
            switch sectionType{
            case .searching:
                groupHeightDimension = .fractionalWidth(0.5)
            case .result:
                groupHeightDimension = .fractionalWidth(0.33)
            }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 4)
            var group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: groupHeightDimension), subitems: [item,item])
            group.contentInsets = .init(top: 4, leading: 16, bottom: 4, trailing: 16)
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(32)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            sectionHeader.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            let section = NSCollectionLayoutSection(group: group)
            switch sectionType{
            case .searching:
                if self.nowStatus == .searching{
                    section.boundarySupplementaryItems = [sectionHeader]
                }
            case .result: break
            }
            return section
        }
        return layout
    }
}
