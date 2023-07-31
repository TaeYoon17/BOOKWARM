//
//  SearchVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit

class SearchVC: UIViewController{
    static let identifier = "SearchVC"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "검색화면"
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "xmark"), style: .plain, target: self, action: #selector(Self.closeBtnTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = .black
    }
    @objc func closeBtnTapped(){
        self.dismiss(animated: true)
    }
}
