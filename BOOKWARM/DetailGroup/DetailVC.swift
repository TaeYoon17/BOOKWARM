//
//  DetailVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit

class DetailVC: UIViewController,MovieObserver{
    enum SegmentType:Int{ case Overview, Memo }
    enum SegueType:String{ case Push = "chevron.left",Modally = "xmark" }
    static let identifier = "DetailVC"
    var movieSubscriber: ((Movie)->())?
    var movie:Movie?{
        didSet{
            guard let movieSubscriber, let movie else {return}
            movieSubscriber(movie)
        }
    }
    var memo:String?{
        didSet{
            print(memo)
        }
    }
    var headerBg: UIColor?
    var segueType: SegueType = .Push
    var placeHolder = "메모를 입력하세요"
    
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
                self.movie?.like = like
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
    @IBAction func rootViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.memoTextView.resignFirstResponder()
    }
    @objc func heartBtnTapped(){
        self.like.toggle()
        self.view.endEditing(true)
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
        self.view.endEditing(true)
        self.segmentType = type
    }
}
//MARK: -- VC 초기 세팅
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
        self.memoTextView.delegate = self
        self.memoTextView.font = .systemFont(ofSize: 20, weight: .medium)
        if let memo, memo.trimmingPrefix([" ","\n"]) != ""{
            self.memoTextView.set(valueType: .Exist(value: memo))
        }else{
            self.memoTextView.set(valueType: .Empty(placeholder: self.placeHolder))
        }
    }
}
extension DetailVC:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        let trimmedText = textView.text.trimmingCharacters(in: [" ","\n"])
        self.memo = trimmedText
        textView.set(stateType: .End(placeholder: self.placeHolder))
        textView.resignFirstResponder()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.set(stateType: .Begin(placeholder: self.placeHolder))
    }
}
fileprivate extension UIBarButtonItem{
    func setLike(like:Bool){
        print(#function)
        self.image = .init(systemName: "heart\(like ? ".fill":"")")
        self.tintColor = like ? .red : .gray
    }
}
fileprivate extension UITextView{
    enum StateType{
        case Begin(placeholder: String)
        case End(placeholder: String)
    }
    enum ValueType{
        case Empty(placeholder: String)
        case Exist(value:String)
    }
    private func set(text:String,color:UIColor){
        self.textColor = color
        self.text = text
    }
    func set(valueType:ValueType){
        switch valueType{
        case .Empty(let p): self.set(text: p, color: .lightGray)
        case .Exist(let v): self.set(text: v,color:.black)
        }
    }
    func set(stateType:StateType){
        switch stateType{
        case .Begin(let placeholder):
            if self.text == placeholder{
                self.set(valueType: .Exist(value: ""))
            }
        case .End(let placeholder):
            if self.text.trimmingCharacters(in: [" ","\n"]) == ""{
                self.set(valueType: .Empty(placeholder: placeholder))
            }
        }
    }
}
