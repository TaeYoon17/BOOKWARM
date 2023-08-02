//
//  Collection.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import Foundation
extension Collection{
    subscript(safe idx:Index) -> Element?{
        get{
            self.indices.contains(idx) ? self[idx] : nil
        }
    }
}
