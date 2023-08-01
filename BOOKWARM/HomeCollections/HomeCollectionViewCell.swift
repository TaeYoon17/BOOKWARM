//
//  HomeCollectionViewCell.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    static let identifier = "HomeCollectionViewCell"
    var btnAction:UIAction?
    var bgColor: UIColor?{
        didSet{
            guard let bgColor else {return}
            self.rootView.backgroundColor = bgColor
        }
    }
    var like:Bool = false {
        didSet{
            if oldValue != like{ self.likeBtnDesign() }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configure()
    }
    private func configure(){
        rootView.layer.cornerRadius = 16
//        posterImgView.clipsToBounds = true
//        titleLabel.clipsToBounds = true
        titleLabel.textColor = .white
        scoreLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 18)
        scoreLabel.font = .preferredFont(forTextStyle: .footnote)
        self.likeBtnDesign()
    }
    func setCell(title:String,score:Double,like:Bool,bgColor: UIColor,_ action:UIAction? = nil){
        self.titleLabel.text = title
        self.scoreLabel.text = String(format: "%.2f", score)
        self.posterImgView.image = .init(named: title)
        self.bgColor = bgColor
    LIKE_BUTTON_ACTION_SET:do {
        self.like = like
        guard let action else { return }
            if let btnAction{ self.likeBtn.removeAction(btnAction, for: .touchUpInside) }
            btnAction = action
            self.likeBtn.addAction(action, for: .touchUpInside)
        }
    }
}
fileprivate extension HomeCollectionViewCell{
    func likeBtnDesign(){
        likeBtn.tintColor = like ? .red : .lightGray
        likeBtn.setImage(.init(systemName: "heart\(like ? ".fill" : "")"), for: .normal)
        likeBtn.setPreferredSymbolConfiguration(.init(scale: .medium), forImageIn: .normal)
    }
}
