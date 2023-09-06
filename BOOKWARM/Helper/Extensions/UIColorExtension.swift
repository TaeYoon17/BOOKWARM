//
//  UIColorExtension.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import Foundation
import UIKit
extension UIColor{
    static var random:UIColor{
        get{
            UIColor(cgColor: .init(red: CGFloat(Float.random(in: 0...1)), green: CGFloat(Float.random(in: 0...1)), blue: CGFloat(Float.random(in: 0...1)), alpha: 1))
        }
    }
}
