//
//  BookCategory.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/04.
//

import Foundation
enum BookCategory:String,CaseIterable{
    case examination
    case novel
    case poem
    case cook
    case health
    case hobby
    case economy
    case history
    case art
    case science
    case computer
    case magazine
}

extension BookCategory{
    static let korean:[Self:String] = [
        .art: "예술",
        .computer: "컴퓨터",
        .cook: "요리",
        .economy: "경제",
        .examination:"수험서",
        .health:"건강",
        .history: "역사",
        .hobby: "취미",
        .magazine: "잡지",
        .novel: "소설",
        .poem:"시",
        .science:"과학"
    ]
}
