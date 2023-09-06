//
//  BookTableRepository.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/06.
//

import Foundation
import RealmSwift
import UIKit

class BaseTableRepository<T> where T: Object{
    let realm = try! Realm()
    var tasks: Results<T>!
    func checkSchemaVersion(){
        do {
            let version = try schemaVersionAtURL(Realm.Configuration.defaultConfiguration.fileURL!)
            print("Schema version: \(version)")
        }catch{
            print(error)
        }
    }
    func fetch(key: String = "",ascending:Bool = false) -> Results<T>{
        self.tasks = realm.objects(T.self).sorted(byKeyPath: key,ascending: ascending)
        return tasks
    }
    func create(item task: T){
        do{
            try realm.write{ realm.add(task) }
        }catch{
            print(error)
        }
    }
    func remove(item task: T){
        do{
            try realm.write{ realm.delete(task) }
        }catch{
            print(error)
        }
    }
    func updateItem<U>(item _task: BookTable,attribute: WritableKeyPath<BookTable,U>,value: U){
        var task = _task
        do {
            try realm.write{ task[keyPath:attribute] = value }
        }catch{
            print(error)
        }
    }
}

final class BookTableRepository: BaseTableRepository<BookTable>{
    //    enum FilterType{ case title((T)->Bool),like }
    //    func filter(by filterType: FilterType)-> Results<T>{
    //        fetch().where {
    //            switch filterType{
    //            case .like:
    //                return $0.diaryLike == true
    //            case .title:
    //                //            .caseInsensitive 대소문자가 없어진다.
    //                return $0.diaryTitle.contains("제목",options: .caseInsensitive)
    //            }
    //        }
    //    }
        // 특정 레코드에 존재하는 값을 바꿀 때, 수정할 때
        //                realm.add(item,update: .modified)
        //                realm.create(T.self,value: ["_id" : id, "diaryTitle" : title,"contents":contents]
        //                             ,update: .modified)
}
extension BookTableRepository{
    enum AttributeType:CaseIterable{
        case like, recent
    }
    
    
    func remove(by: Set<WritableKeyPath<BookTable, Bool?>>,completion:(()->())? = nil){
        let datas = realm.objects(BookTable.self)
        // 갖고 있는 Attributes 중 특정 Attribute를 전부 False 처리한다.
        by.forEach{ by in datas.forEach { _table in
                var table = _table
                try? realm.write{ table[keyPath:by] = false }
            }
        }
        // 하나라도 true가 없으면 이 데이터는 없앤다
        do{
            try self.realm.write{
                datas.filter { $0.like != true && $0.recent != true }
                    .forEach {
                        removeImageFromDocument(fileName: "\($0.isbn).jpg")
                        realm.delete($0)
                    }
            }
        }catch{
            print(error)
        }
        completion?()
    }
    func remove(byby: [AttributeType],completion:(()->())? = nil){
        let datas = realm.objects(BookTable.self)
        // 갖고 있는 Attributes 중 특정 Attribute를 전부 False 처리한다.
        byby.forEach { type in
            switch type{
            case .like: datas.forEach { table in
                try? realm.write{ table.like = false }
            }
            case .recent: datas.forEach { table in
                try? realm.write{ table.recent = false }
            }
            }
        }
        // 하나라도 true가 없으면 이 데이터는 없앤다
        do{
            try self.realm.write{
                datas
                    .filter { $0.like != true && $0.recent != true }
                    .forEach {
                        removeImageFromDocument(fileName: "\($0.isbn).jpg")
                        realm.delete($0)
                    }
            }
        }catch{
            print(error)
        }
        completion?()
    }
    func removeAll(){
        remove(by: [\.recent,\.like])
    }
    private func removeImageFromDocument(fileName:String){
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let fileURL = documentDir.appendingPathComponent(fileName)
        do{
            try FileManager.default.removeItem(at: fileURL)
        }catch{
            print(error)
        }
    }
}
//        removeImageFromDocument(fileName: "shot_\(task._id).jpg")
//        try! realm.write{
//            realm.delete(task)
//        }
