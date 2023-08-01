//
//  HomeCollectionVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit

class HomeCollectionVC: UICollectionViewController{
    static let identifier = "HomeCollectionVC"
    var infos = MovieInfo(){
        didSet{ self.collectionView.reloadData() }
    }
    lazy var datasBgColor: [UIColor] = {
        (0..<infos.movie.count).map{_ in .random}
    }()
    let cellName = HomeCollectionViewCell.identifier
    var selectedRow: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        self.collectionView.register(.init(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
//        self.navigationItem.title = "고래밥님의 책상"
        setCollectionLayouts()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "고래밥님의 책상"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .white
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    @IBAction func searchItemTapped(_ sender: UIBarButtonItem) {
        print(#function)
        guard let vc = storyboard?.instantiateViewController(withIdentifier: SearchVC.identifier) as? SearchVC else {
            print("이건 안된다..!")
            return
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    private func setCollectionLayouts(){
        let layout = UICollectionViewFlowLayout()
        let spacing:CGFloat = 20; let groupItemsCount = 2;
        let cellWidth: Int = (Int(UIScreen.main.bounds.width) -
                              Int(spacing) * (groupItemsCount + 1)) / groupItemsCount
        guard cellWidth > 0  else { fatalError("이건 아니지") }
        layout.itemSize = .init(width: cellWidth,height: cellWidth)
        layout.sectionInset = .init(top: spacing, left: spacing,
                                    bottom: spacing, right: spacing)
        // 그룹간의 간격
        layout.minimumLineSpacing = spacing
        // 아이템간의 간격
        layout.minimumInteritemSpacing = spacing
        collectionView.collectionViewLayout = layout
    }
}

extension HomeCollectionVC{
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? HomeCollectionViewCell else {
            print("무엇인가 잘못됨!!")
            return .init()
        }
        guard let info:Movie = infos.movie[safe: indexPath.row],let color = self.datasBgColor[safe: indexPath.row] else {
            print("진짜 대형 사고")
            return .init()
        }
        cell.setCell(title: info.title, score: info.rate,like:info.like
                     ,bgColor: color,.init(handler: { _ in
            cell.like.toggle()
        }))
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        infos.movie.count
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DetailVC.identifier) as? DetailVC, let info:Movie = infos.movie[safe: indexPath.row] else {
            return
        }
        self.selectedRow = indexPath.row
        guard let selectedRow, let color = datasBgColor[safe: selectedRow] else {return}
//        vc.movieTitle = info.title
        vc.movie = info
        vc.headerBg = color
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
