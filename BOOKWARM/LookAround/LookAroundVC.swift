//
//  LookAroundVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/08/02.
//

import Foundation
import UIKit

struct RecentIdxList{
    public private(set) var list:[Int] = []
    mutating func append(idx value:Int){
        if let firstListIdx = list.firstIndex(of: value),firstListIdx == list.startIndex{
            return
        }
        if let firstListIdx = list.firstIndex(of: value){
            list.remove(at: firstListIdx)
        }
        list.insert(value, at: 0)
    }
    mutating func remove(idx value: Int){
        list.removeAll { val in val == value }
    }
    func getModelIdx(row: Int)->Int?{
        self.list[safe: row]
    }
}

class LookAroundVC: UIViewController{
    static let identifier = "LookAroundVC"
    fileprivate var nextVC_Identifier = DetailVC.identifier
    typealias NextVC = DetailVC
    var movieInfoModel = MovieInfo()
    var recentMovieIdxList = RecentIdxList(){
        didSet{
            guard oldValue.list != recentMovieIdxList.list else { return }
            self.headerCollectionView.reloadData()
        }
    }
    lazy var datasBgColor: [UIColor] = {
        (0..<movieInfoModel.movie.count).map{_ in .random}
    }()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureCollectionView()
        //MARK: -- 임시 데이터 뷰
        (0...4).forEach{recentMovieIdxList.append(idx: $0)}
    }
    func presentNextView(index: Int){
        guard let _vc = storyboard?.instantiateViewController(withIdentifier: self.nextVC_Identifier) as? NextVC else { return }
        _vc.segueType = .Modally
//        _vc.movie = movieInfoModel.movie[safe: index]
        _vc.headerBg = datasBgColor[safe: index]
//        _vc.movieSubscriber = {[weak self] movie in
//            guard let self else {return}
//            self.movieInfoModel.movie[index] = movie
//        }
        let vc = UINavigationController(rootViewController: _vc)
        vc.navigationController?.navigationBar.scrollEdgeAppearance = .init()
        vc.navigationBar.scrollEdgeAppearance = .init()
        vc.navigationBar.scrollEdgeAppearance?.shadowColor = .clear
        vc.navigationBar.barTintColor = .clear
        vc.modalPresentationStyle = .fullScreen
        if let sheet = vc.sheetPresentationController{
            sheet.detents = [.medium(),.large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
    func presentNextView(indexPath: IndexPath){
        presentNextView(index:indexPath.row)
    }
}

extension LookAroundVC: UITableViewDelegate,UITableViewDataSource{
    fileprivate var topCellIdentifier:String{ TopItemTableViewCell.identifier }
    typealias TopCell = TopItemTableViewCell
    fileprivate func configureTableView(){
        let nib = UINib(nibName: topCellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: topCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 128
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: topCellIdentifier) as? TopCell,
              let data = movieInfoModel.movie[safe: indexPath.row] else { return .init()}
        cell.configure(data: data)
        cell.movieSubscriber = {[weak self] movie in
            self?.movieInfoModel.movie[indexPath.row] = movie
            print(self?.movieInfoModel.movie[indexPath.row].like)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieInfoModel.movie.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "요즘 인기 작품"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentNextView(indexPath: indexPath)
        print(indexPath.row)
        self.recentMovieIdxList.append(idx: indexPath.row)
    }
}

extension LookAroundVC: UICollectionViewDelegate,UICollectionViewDataSource{
    fileprivate var recentCellIdentifier:String{ RecentItemCell.identifier }
    typealias RecentCell = RecentItemCell
    func configureCollectionView(){
        self.headerCollectionView.delegate = self
        self.headerCollectionView.dataSource = self
        self.headerCollectionView.register(.init(nibName: recentCellIdentifier, bundle: nil), forCellWithReuseIdentifier: recentCellIdentifier)
        self.headerCollectionView.collectionViewLayout = configureLayout
    }
    private var configureLayout: UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        let height = 128; let width = 52 * height / 74
        layout.itemSize = .init(width: width, height: height)
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        return layout
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.recentMovieIdxList.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentItemCell.identifier, for: indexPath) as? RecentItemCell,
              let modelIdx = recentMovieIdxList.getModelIdx(row: indexPath.row),
              let data = movieInfoModel.movie[safe: modelIdx]
        else { return .init() }
        
        cell.configure(title: data.title)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let idx = recentMovieIdxList.list[indexPath.row]
        print(idx) // 이스터에그
        presentNextView(index:idx)
        recentMovieIdxList.append(idx: idx)
    }
    
}
