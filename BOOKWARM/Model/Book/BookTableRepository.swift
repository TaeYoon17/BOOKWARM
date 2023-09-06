//
//  BookTableRepository.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/09/06.
//

import Foundation
import RealmSwift
final class TableRepository<T> where T: Object{
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
    func createItem(_ task: T){
        do{
            try realm.write{
                realm.add(task)
                print("Real Add Succeed")
            }
        }catch{
            print(error)
        }
    }
    func updateItem(action:()->()){
        do {
            try realm.write{
                // 특정 레코드에 존재하는 값을 바꿀 때, 수정할 때
//                realm.add(item,update: .modified)
//                realm.create(T.self,value: ["_id" : id, "diaryTitle" : title,"contents":contents]
//                             ,update: .modified)
                action()
            }
        }catch{
            print(error)
        }

    }
}
