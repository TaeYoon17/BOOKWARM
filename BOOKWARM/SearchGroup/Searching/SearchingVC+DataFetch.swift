//
//  SearchingVC+DataFetch.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/05.
//

import Foundation
import UIKit
extension SearchingVC{
    func dataSourceUpdating(){
        func dataSourceToSearching(){ // 검색 중 일 때 가져올 데이터
            DispatchQueue.main.async {
                let recentItems:[Item] = self.tasks.filter {
                    guard let recent = $0.recent else {return false}
                    return recent
                }.map{.recent(item: $0, color: .random)}
                var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                self.collectionView.collectionViewLayout = self.compositionalLayout
                snapshot.appendSections([.searching])
                snapshot.appendItems(recentItems,toSection: .searching)
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
        case .result: dataSourceToResult()
        case .searching: dataSourceToSearching()
        }
    }
}

