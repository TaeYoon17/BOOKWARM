//
//  SearchMainVC + UICollectionView.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/04.
//

import UIKit
extension SearchMainVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bookmodel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {return .init()}
        let book = bookmodel[indexPath.row]
        cell.bgColor = self.bookListColor[indexPath.row]
        cell.searchVC_Configure(title: book.title, thumbnailURL: book.thumbnailURL, price: book.price)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            print(#function,indexPath.row,self.bookmodel.count)
//            if indexPath.row > self.bookmodel.count - 5, requestedPage < BookRouter.maxPage,!self.isEnded{
//                //여기서 request 로직 수행
//                self.fetchList()
//            }
        }
    }
    
    func configureCollectionView(){
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.prefetchDataSource = self
        self.collectionView.register(.init(nibName: HomeCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemYellow
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    var compositionalLayout: UICollectionViewLayout{
        var layout = UICollectionViewCompositionalLayout { index, environment in
            guard let sectionType = Section(rawValue: index) else {fatalError("이건 안되용~")}
            var section: NSCollectionLayoutSection
            switch sectionType{
            case .result:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                var group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5)), subitems: [item,item])
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
            case .keyword:
                var config = UICollectionLayoutListConfiguration(appearance: .plain)
                section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
            }
            return section
        }
        return layout
    }
}
