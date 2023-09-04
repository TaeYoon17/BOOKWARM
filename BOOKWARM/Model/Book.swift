//
//  Book.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/08/09.
//

import Foundation
struct Book: Codable{
    let authors: [String]
    let conetnts: String
    let datetime: Date
    let isbn: String
    let price: Int
    let publisher:String
    let slae_price: Int
    let status: String
    let thumbnailURL: String
    let title: String
    let translators: [String]
    let linkURL: String
}
/*
{
  "authors": [
    "기시미 이치로",
    "고가 후미타케"
  ],
  "contents": "인간은 변할 수 있고, 누구나 행복해 질 수 있다. 단 그러기 위해서는 ‘용기’가 필요하다고 말한 철학자가 있다. 바로 프로이트, 융과 함께 ‘심리학의 3대 거장’으로 일컬어지고 있는 알프레드 아들러다. 『미움받을 용기』는 아들러 심리학에 관한 일본의 1인자 철학자 기시미 이치로와 베스트셀러 작가인 고가 후미타케의 저서로, 아들러의 심리학을 ‘대화체’로 쉽고 맛깔나게 정리하고 있다. 아들러 심리학을 공부한 철학자와 세상에 부정적이고 열등감 많은",
  "datetime": "2014-11-17T00:00:00.000+09:00",
  "isbn": "8996991341 9788996991342",
  "price": 14900,
  "publisher": "인플루엔셜",
  "sale_price": 13410,
  "status": "정상판매",
  "thumbnail": "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1467038",
  "title": "미움받을 용기",
  "translators": [
    "전경아"
  ],
  "url": "https://search.daum.net/search?w=bookpage&bookId=1467038&q=%EB%AF%B8%EC%9B%80%EB%B0%9B%EC%9D%84+%EC%9A%A9%EA%B8%B0"
},
*/
