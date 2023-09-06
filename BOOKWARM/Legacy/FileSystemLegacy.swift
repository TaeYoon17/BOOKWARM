//
//  FileSystemExtension.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/05.
//

import UIKit

//MARK: -- Legacy 도큐먼트 관련 이미지 처리
//extension UIViewController{
    // 도큐먼트 폴더에서 이미지를 가져오는 메서드
//    func loadImageFromDocument(fileName: String)->UIImage?{
//        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            return UIImage(systemName: "star.filled")!
//        }
//        let fileURL = documentDir.appendingPathComponent(fileName)
//
//        if FileManager.default.fileExists(atPath: fileURL.path){
//            return UIImage(contentsOfFile: fileURL.path)
//        }else{
//            return UIImage(systemName: "star.fill")
//        }
//    }
//    func saveImageToDocument(fileName:String,image: UIImage){
//        //1. 도큐먼트 경로 찾기
//        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        //2. 저장할 파일의 세부 경로 설정
//        let fileURL = documentDir.appendingPathComponent(fileName)
//        //3. 이미지 변환 -> 세부 경로 파일을 열어서 저장
//        guard let data = image.jpegData(compressionQuality: 0.6) else {return}
//        //4. 이미지 저장
//        do{
//            try data.write(to: fileURL)
//        }catch let err{
//            print("file save error",err)
//        }
//    }
//}
