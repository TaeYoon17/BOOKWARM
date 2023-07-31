//
//  DetailVC.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit

class DetailVC: UIViewController{
    static let identifier = "DetailVC"
    var movieTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = movieTitle
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "chevron.left"), style: .plain, target: self, action: #selector(Self.popVC))
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }
    @objc func popVC(){
        self.navigationController?.popViewController(animated: true)
    }
}
