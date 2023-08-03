//
//  HomeCollectionVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit

class HomeCollectionVC: UICollectionViewController{
    static let identifier = "HomeCollectionVC"
    enum ViewType{
        case Search
        case Read
    }
    lazy var model = HomeModel(infoType: .Read)
    let cellName = HomeCollectionViewCell.identifier
    var selectedRow: Int?
    var viewType: ViewType = .Read{
        didSet{
            guard viewType != oldValue else {return}
            switch viewType{
            case .Read: model.infoType = .Read
            case .Search: model.infoType = .Search
            }
            self.collectionView.reloadData()
        }
    }
    var searchText: String = ""{
        didSet{
            model.setSearchList(searchText: searchText)
            self.collectionView.reloadData()
        }
    }
    lazy var searchBar = {
        let bar = UISearchBar()
        bar.placeholder = "영화를 입력하세요"
        bar.delegate = self
        return bar
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(.init(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        setCollectionLayouts()
        self.navigationItem.titleView = searchBar
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        // 터치 시, 현재 뷰의 터치를 취소합니다. 기본값은 true이며, 상호작용이 필요하면 false로 처리
        tapGesture.cancelsTouchesInView = false
        self.collectionView.addGestureRecognizer(tapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "고래밥님의 책상"
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .white
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    @objc func tapHandler() {
        self.searchBar.endEditing(true)
        // KVO
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
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
    
}
//MARK: -- 서치바 Delegate
extension HomeCollectionVC: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        print(#function)
        self.viewType = .Search
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.searchText = searchText
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        self.model.setSearchList(searchText: "")
        self.viewType = .Read
    }
}
//MARK: -- 컬렉션 뷰 설정
extension HomeCollectionVC{
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? HomeCollectionViewCell else {
            print("무엇인가 잘못됨!!")
            return .init()
        }
        print(indexPath.row)
        guard let (info,color) = model.getMovieModel(idx: indexPath.row) else {
            print("진짜 대형 사고")
            return .init()
        }
        cell.setCell(title: info.title, score: info.rate, like:info.like, bgColor: color,
                     .init(handler: { _ in cell.like.toggle() }))
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.count
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DetailVC.identifier) as? DetailVC
        else {
            return
        }
        guard let (info,color) = model.getMovieModel(idx: indexPath.row) else {return}
        vc.movie = info
        vc.headerBg = color
        self.navigationController?.pushViewController(vc, animated: true)
    }
    fileprivate func setCollectionLayouts(){
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
