//
//  DetailVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit

class DetailVC: UIViewController{
    static let identifier = "DetailVC"
    var movie:Movie?
    var headerBg: UIColor?
    enum SegmentType:Int{
        case Overview
        case Memo
    }
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
            self.navigationItem.rightBarButtonItem?.setLike(like: like)
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
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "chevron.left"), style: .plain, target: self, action: #selector(Self.popVC))
        self.navigationItem.rightBarButtonItem = .init(image: .init(systemName: "heart.fill"), style: .plain, target: self, action: #selector(Self.heartBtnTapped))
        guard let movie else {return}
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
        self.navigationController?.popViewController(animated: true)
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
        self.image = .init(systemName: "heart\(like ? ".fill":"")")
        self.tintColor = like ? .red : .gray
    }
}
