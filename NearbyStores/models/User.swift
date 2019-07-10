//
//  User.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift


class User : Object {

    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: Int = 0;
    @objc dynamic var senderid: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var job: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var phone: String = ""
    @objc dynamic var country: String = ""
    @objc dynamic var city: String = ""
    @objc dynamic var token: String = "";
    @objc dynamic var auth: String = ""
    @objc dynamic var images: Images? = nil
    @objc dynamic var status: Int = 0
    @objc dynamic var followed: Bool = false;
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var distance: Double = 0
    @objc dynamic var tokenGCM: String = "";
    @objc dynamic var online: Bool = false
    @objc dynamic var blocked: Bool = false
    
    
    enum Types {
        static var MANGER: String = "manager"
        static var ADMIN: String = "admin"
        static var CUSTOMER: String = "customer"
    }
    
    enum Tags{
        static var ID: String = "id_user"
        static var USERNAME: String = "username"
        static var PASSWORD: String = "password"
        static var EMAIL: String = "email"
        static var PHONE: String = "phone"
        static var FIRSTNAME: String = "name"
        static var LASTNAME: String = "lastname"
        static var AUTH: String = "auth_type"
        static var STATUS: String = "status"
        static var IMAGES: String = "images"
        static var IMAGE_100: String = "image100"
        static var IMAGE_200: String = "images200"
        static var IMAGE_500: String = "images500"
        static var FOLLOWED: String = "followed"
        static var GCMTOKEN: String = "gcmtoken"
        static var TYPE: String = "type"
        static var SENDERID: String = "senderid"
        
    }
    
}

extension User {
    
    func save() {
        if self.id > 0 {
            let user = self

            let realm = try! Realm()
            realm.beginWrite()
            realm.add(user,update: true)
            try! realm.commitWrite()
            
        }
    }
    
    
    static func findById(id: Int) -> User? {
        
        let realm = try! Realm()
        
        if let user = realm.objects(User.self).filter("id == \(id)").first {
            return user
        }
        
        return nil
    }
    
    
    func setBlockState(_ state: Bool) {
        
        let user = self
        let realm = try! Realm()
        realm.beginWrite()
        user.blocked = state
        realm.add(user,update: true)
        try! realm.commitWrite()
        
    }
    
   
    
    
}

extension Array where Element:User {
    
    func saveAll(){
       
        let users: [User] = self
        
        if users.count > 0 {
            
            let realm = try! Realm()
            
            realm.beginWrite()
            realm.add(users,update: true)
            try! realm.commitWrite()
            
        }
        
    }
    
    func getindex(user_id: Int) -> Int? {
        
        var users: [User] = self
        
        
        //resfresh item to the top
        let size = users.count - 1
        
        if size >= 0 {
            
            for index in 0...users.count {
                
                if users[index].id == user_id{
                    return index
                }
                
            }
            
        }
        
        
        return nil
        
    }
}



