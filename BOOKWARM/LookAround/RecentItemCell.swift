//
//  RecentItemCell.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/08/02.
//

import UIKit

class RecentItemCell: UICollectionViewCell {
    static let identifier = "RecentItemCell"
    @IBOutlet weak var posterImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(title:String){
        self.posterImgView.image = .init(named: title)
    }
}
