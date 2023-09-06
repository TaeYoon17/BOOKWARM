//
//  AppDelegate.swift
//  BOOKWARM
//
//  Created by 김태윤 on 2023/07/31.
//

import UIKit
import RealmSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().tintColor = .black
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        // 기본 oldSchema 숫자는 0에서 시작한다.
        let config = Realm.Configuration(schemaVersion: 3){ migration, oldSchema in
            if oldSchema < 1{            }
            if oldSchema < 2{
                migration.enumerateObjects(ofType: BookTable.className()) { oldObject, newObject in
                    guard let new = newObject else {return}
                    guard let old = oldObject else {return}
                    new["recent"] = true
                    
                }
            }
            if oldSchema < 3{
                migration.enumerateObjects(ofType: BookTable.className()) { oldObject, newObject in
                    guard let new = newObject else {return}
                    guard let old = oldObject else {return}
                    new["recent"] = true
                    new["like"] = false
                }
                
            }
        }
        Realm.Configuration.defaultConfiguration = config
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

