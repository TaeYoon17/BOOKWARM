//
//  TopItemTableViewCell.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/08/02.
//

import UIKit

class TopItemTableViewCell: UITableViewCell,MovieObserver {
    static let identifier = "TopItemTableViewCell"
    var likeAction: UIAction?
    var movieSubscriber: ((Movie)->())?
    public internal(set) var movie: Movie?{
        didSet{
            guard let movieSubscriber,let movie else{return}
            movieSubscriber(movie)
        }
    }
    @IBOutlet weak var posterImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var release_runLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    lazy var like:Bool = false {
        didSet{
            guard like != oldValue else {return}
            self.likeBtn.setLike(like: like)
            self.movie?.like = like
        }
    }
    lazy var release_runText = ""{
        didSet{
            release_runLabel.text = release_runText
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func configure(data:Movie){
        self.like = true
        self.movie = data
        self.posterImgView.image = .init(named: data.title)
        self.titleLabel.text = data.title
        self.scoreLabel.text = data.rate.getDecimalPoint(2)
        let releaseYear = String(data.releaseDate.split(separator: ".").first ?? "")
        self.release_runText = "\(releaseYear)년 출시 · \(data.runtime)분"
        if let likeAction{ self.likeBtn.removeAction(likeAction, for: .touchUpInside) }
        self.likeAction = .init(handler: {[weak self] _ in self?.like.toggle() })
        guard let likeAction else {return}
        self.likeBtn.addAction(likeAction, for: .touchUpInside)
        self.like = data.like
        print(self.like)
    }
}

extension Double{
    func getDecimalPoint(_ pointCount: Int)->String{
        String(format: "%.\(pointCount)f", self)
    }
}
fileprivate extension UIButton{
    func setLike(like:Bool){
        self.setImage(.init(systemName: "heart\(like ? ".fill":"")"), for: .normal)
        self.tintColor = like ? .red : .gray
    }
}
