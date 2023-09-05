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
    enum Section:Int{ case searching,result }
    enum Item:Hashable{
        case book(item:Book,color:UIColor?)
    }
    var nowStatus = Section.searching
    var collectionView: UICollectionView!
    var diffableDataSource: UICollectionViewDiffableDataSource<Section,Item>!
    var bookListColor:[UIColor] = []
    var bookmodel: [Book] = []
    var searchText = ""
    var requestedPage = 0
    var isEnded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
    
        configureCollectionView()
        configureDataSource()
    }
    func configureDataSource(){
        //MARK:-- 헤더를 넣을 수도..?
//        let keywordHeaderRegistration = UICollectionView.SupplementaryRegistration<TempHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
//            guard let section = Section(rawValue: indexPath.section) else {return}
//            supplementaryView.titleLabel.text = section.koreanDescription
//            supplementaryView.titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
//        }
        let resultcCellRegistration = UICollectionView.CellRegistration<HomeCollectionViewCell,Item>{[weak self] cell, indexPath, item in
            switch item{
            case .book(item: let item,color: let color):
                cell.bgColor = color
                cell.searchVC_Configure(title: item.title, thumbnailURL: item.thumbnailURL, price: item.price)
            default: fatalError("이럴 수가 없음..!")
            }
        }
        self.diffableDataSource = UICollectionViewDiffableDataSource<Section,Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {return UICollectionViewCell()}
            cell.bgColor = self.bookListColor[indexPath.row]
            switch item{
            case .book(item: let item,color: _):
                cell.searchVC_Configure(title: item.title, thumbnailURL: item.thumbnailURL, price: item.price)
            }
            return cell
        })
        //MARK: -- 헤더를 넣을 수도..?
//        self.diffableDataSource.supplementaryViewProvider = { c,elementKind,indexPath -> UICollectionReusableView? in
//            guard let section = Section(rawValue: indexPath.section) else {return nil}
//            switch elementKind{
//            case UICollectionView.elementKindSectionHeader:
//                switch section{
//                case .keyword:
//                    let cell = c.dequeueConfiguredReusableSupplementary(using: keywordHeaderRegistration, for: indexPath)
//                    DispatchQueue.main.async{
//                        cell.layer.cornerRadius = 20
//                    }
//                    return cell
//                case .result:
//                    return c.dequeueConfiguredReusableSupplementary(using: resultHeaderRegistration, for: indexPath)
//                }
//            default: return nil
//            }
//        }
        dataSourceToResult()
    }
    func dataSourceToSearching(){ }
    func dataSourceToResult(){
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.result])
        let items:[Item] = zip(bookmodel, bookListColor).map{.book(item:$0,color:$1)}
        snapshot.appendItems(items,toSection: .result)
        self.diffableDataSource.apply(snapshot,animatingDifferences: true)
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
                        DispatchQueue.main.async {
                            self?.dataSourceToResult()
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
        if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - 40{
            searchQuery()
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {return}
        switch item{
        case let .book(item: book, color: _):
            let realm = try! Realm()
            let task = BookTable(book: book)
            try! realm.write{
                realm.add(task)
                print(task)
                print("Real Add Succeed")
            }
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
//            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
        return layout
    }
}
