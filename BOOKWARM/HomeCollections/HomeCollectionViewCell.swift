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
    static let identifier = "HomeCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configure()
    }
    private func configure(){
        rootView.layer.cornerRadius = 16
        rootView.backgroundColor = .random
//        posterImgView.clipsToBounds = true
//        titleLabel.clipsToBounds = true
        titleLabel.textColor = .white
        scoreLabel.textColor = .white
//        UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .title3))
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        scoreLabel.font = .preferredFont(forTextStyle: .footnote)
    }
    func setCell(title:String,score:Double){
        self.titleLabel.text = title
        self.scoreLabel.text = String(format: "%.2f", score)
        self.posterImgView.image = .init(named: title)
    }
}
