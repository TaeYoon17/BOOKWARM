//
//  SearchMainVC + UICollectionView.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/04.
//

import UIKit
import SnapKit
extension SearchMainVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else {return 0}
        switch sectionType{
        case .keyword:
            return categoryModel.count
        case .result:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {return .init()}
        switch section{
        case .keyword:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UICollectionViewListCell.self), for: indexPath) as? UICollectionViewListCell else {return .init()}
            var config = cell.defaultContentConfiguration()
            print(indexPath.row)
            config.text = BookCategory.korean[self.categoryModel[indexPath.row]]
            cell.contentConfiguration = config
            return cell
        case .result:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as? HomeCollectionViewCell else {return .init()}
            let book = bookmodel[indexPath.row]
            cell.bgColor = self.bookListColor[indexPath.row]
            cell.configureByBook(title: book.title, thumbnailURL: book.thumbnailURL, price: book.price)
            return cell
        }
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
//        self.collectionView.dataSource = self
//        self.collectionView.prefetchDataSource = self
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
    }
    var compositionalLayout: UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { index, environment in
            guard let sectionType = Section(rawValue: index) else {fatalError("이건 안되용~")}
            let groupHeightDimension: NSCollectionLayoutDimension
            switch sectionType{
            case .result:
                groupHeightDimension = .fractionalWidth(0.5)
            case .keyword:
                groupHeightDimension = .fractionalWidth(0.33)
            }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 4)
            var group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: groupHeightDimension), subitems: [item,item])
            group.contentInsets = .init(top: 4, leading: 16, bottom: 4, trailing: 16)
            var sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(32)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            sectionHeader.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            var section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        }
        return layout
    }
}
class TempHeaderView: UICollectionReusableView{
    let titleLabel = UILabel()
    var trailingBtn :UIButton?{
        didSet{
            guard let trailingBtn else {return}
            self.addSubview(trailingBtn)
            trailingBtn.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.verticalEdges.equalToSuperview()
                make.leading.equalTo(titleLabel.snp.trailing)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.text = "이걸 여기에서..!"
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("여기는 원래 안됩니다...")
    }
}
class KeywordCell: UICollectionViewCell{
    let imageView = UIImageView()
    let infoLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.addSubview(imageView)
        self.addSubview(infoLabel)
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        infoLabel.font = .preferredFont(forTextStyle: .headline)
        infoLabel.backgroundColor = .init(white: 1, alpha: 0.5)
        imageView.contentMode = .scaleToFill
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        infoLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(12)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("여기는 원래 안됩니다...")
    }
}
