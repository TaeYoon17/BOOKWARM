//
//  File.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/06.
//

import UIKit
extension UIImage{
    convenience init?(fileName: String) {
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.init(systemName: "star.filled")
            return
        }
        let fileURL = documentDir.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path){
            self.init(contentsOfFile: fileURL.path)
        }else{
            self.init(systemName: "star.filled")
        }
    }
    func saveToDocument(fileName: String){
        //1. 도큐먼트 경로 찾기
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        //2. 저장할 파일의 세부 경로 설정
        let fileURL = documentDir.appendingPathComponent(fileName)
        //3. 이미지 변환 -> 세부 경로 파일을 열어서 저장
        guard let data = self.jpegData(compressionQuality: 0.6) else {return}
        //4. 이미지 저장
        do{
            try data.write(to: fileURL)
        }catch let err{
            print("file save error",err)
        }
    }
}
