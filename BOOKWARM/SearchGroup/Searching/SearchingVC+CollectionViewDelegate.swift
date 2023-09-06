//
//  SearchingVC+CollectionViewDelegate.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/05.
//

import Foundation
import UIKit
extension SearchingVC:UICollectionViewDelegate,UIScrollViewDelegate,UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            print(#function,indexPath.row,self.bookmodel.count)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let canScroll = scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - 40
        if canScroll && nowStatus == .result{ searchQuery() }
        searchBar.endEditing(true)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath),
              let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: DetailVC.identifier) as? DetailVC else {return }
        let newTask: BookTable
        switch item{
        case let .result(item: book, color: _):
            newTask = BookTable(book: book)
            DispatchQueue.global().async {
                guard let url = URL(string: book.thumbnailURL ?? ""),
                      let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    image.saveToDocument(fileName: "\(newTask.isbn).jpg")
                    vc.imageView.image = image
                }
            }
            repository.create(item: newTask)
        case .recent(item: let task, color: _):
            newTask = task
        }
        vc.item = newTask
        vc.navigationItem.largeTitleDisplayMode = .never
        mainVC.navigationController?.pushViewController(vc, animated: true)
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
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: groupHeightDimension), subitems: [item,item])
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
