//
//  DetailVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit

class DetailVC: UIViewController,MovieObserver{
    enum SegmentType:Int{
        case Overview, Memo
    }
    enum SegueType:String{ case Push = "chevron.left",Modally = "xmark" }
    static let identifier = "DetailVC"
    var movieSubscriber: ((Movie)->())?
    var movie:Movie?{
        didSet{
            guard let movieSubscriber, let movie else {return}
            movieSubscriber(movie)
        }
    }
    var headerBg: UIColor?
    var segueType: SegueType = .Push
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var rateLabel: UILabel!
    //MARK: -- 디자인만 고려하는 뷰
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var headerBgView: UIView!
    //MARK: -- 세그먼트 값 레이블
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var overviewLabel: UILabel!
    // 프로퍼티 바인딩 이용하기
    private lazy var like: Bool = true{
        didSet{
            guard like != oldValue else {return}
            if let item = self.navigationItem.rightBarButtonItem{
                item.setLike(like: like)
            }else {
                print("이상하다")
            }
        }
    }
    private lazy var segmentType:SegmentType? = nil{
        didSet{
            guard let segmentType else {return}
            switch segmentType{
            case .Memo:
                overviewLabel.isHidden = true
                memoTextView.isHidden = false
            case .Overview:
                overviewLabel.isHidden = false
                memoTextView.isHidden = true
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.title = movieTitle
        
        self.segmentView.layer.cornerRadius = 20
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: segueType.rawValue)
                                                      , style: .plain, target: self, action: #selector(Self.popVC))
        self.navigationItem.rightBarButtonItem = .init(image: .init(systemName: "heart.fill"),
                                                       style: .plain, target: self, action: #selector(Self.heartBtnTapped))
        guard let movie else {return}
        self.like.toggle()
        self.like = movie.like
        configure()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let headerBg else { return }
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = headerBg
        self.headerBgView.backgroundColor = headerBg
    }
    @objc func heartBtnTapped(){
        self.like.toggle()
    }
    @objc func popVC(){
        switch segueType {
        case .Push:
            self.navigationController?.popViewController(animated: true)
        case .Modally:
            self.dismiss(animated: true)
        }
    }
    @IBAction func segmentTapped(_ sender: UISegmentedControl) {
        guard let type = SegmentType(rawValue: sender.selectedSegmentIndex) else {return}
        self.segmentType = type
    }
}
extension DetailVC{
    func configure(){
        guard let movie else {return}
        titleLabel.text = movie.title
        playTimeLabel.text = "상영 시간: \(movie.runtime)분"
        releaseDateLabel.text = "출시일: \(movie.releaseDate)"
        rateLabel.text = "평점: \(String(format: "%.2f",movie.rate))"
        imageView.image = .init(named: movie.title)
        overviewLabel.text = movie.overview
        self.segmentType = .Overview
    }
}

fileprivate extension UIBarButtonItem{
    func setLike(like:Bool){
        print(#function)
        self.image = .init(systemName: "heart\(like ? ".fill":"")")
        self.tintColor = like ? .red : .gray
    }
}
