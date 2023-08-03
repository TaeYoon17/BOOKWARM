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
    class ViewModel{
        var collectionView: UICollectionView
        public private(set) var infos = MovieInfo()
        public private(set) var searchedMovies:[Movie] = []{
            didSet{
                print(searchedMovies)
                self.collectionView.reloadData()
            }
        }
        var searchedIdx:[Int] = []
        lazy var datasBgColor: [UIColor] = { (0..<infos.movie.count).map{_ in .random} }()
        var searchedBgColors: [UIColor] = []
        var viewType:ViewType
        init(viewType: ViewType,collectionView: UICollectionView){
            self.viewType = viewType
            self.collectionView = collectionView
        }
        func getMovie(idx:Int)->Movie?{
            switch viewType{
            case .Read:
                return self.infos.movie[safe: idx]
            case .Search:
                return self.searchedMovies[safe: idx]
            }
        }
        func getColor(idx:Int)-> UIColor?{
            switch viewType{
            case .Read:
                return self.datasBgColor[safe: idx]
            case .Search:
                return self.searchedBgColors[safe: idx]
            }
        }
        var count:Int{
            switch viewType{
            case .Read: return infos.movie.count
            case .Search: return searchedMovies.count
            }
        }
        func setSearchList(searchText:String){
            self.searchedIdx = self.infos.movie.enumerated()
                .filter{$0.1.title.contains(searchText)}
                .map{$0.0}
            self.searchedMovies = self.searchedIdx.map{self.infos.movie[$0]}
            self.searchedBgColors = self.searchedIdx.map{self.datasBgColor[$0]}
        }
    }
    lazy var model = ViewModel(viewType: viewType,collectionView: self.collectionView)
    let cellName = HomeCollectionViewCell.identifier
    var selectedRow: Int?
    var viewType: ViewType = .Read{
        didSet{
            guard viewType != oldValue else {return}
            model.viewType = viewType
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
        self.navigationItem.title = "고래밥님의 책상"
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
        print(#function)
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
//MARK: -- 서치바 Delegate
extension HomeCollectionVC: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        print(#function)
        self.viewType = .Search
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.model.setSearchList(searchText: searchText)
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
        guard let info:Movie = model.getMovie(idx: indexPath.row), let color = model.getColor(idx: indexPath.row)else {
            print("진짜 대형 사고")
            return .init()
        }
        cell.setCell(title: info.title,
                     score: info.rate,
                     like:info.like,
                     bgColor: color,
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
        guard let info:Movie = model.getMovie(idx: indexPath.row) else {return}
        self.selectedRow = indexPath.row
        guard let selectedRow, let color = model.getColor(idx: selectedRow) else {return}
        vc.movie = info
        vc.headerBg = color
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
