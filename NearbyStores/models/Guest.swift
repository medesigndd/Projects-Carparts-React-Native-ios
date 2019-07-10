//
//  Guest.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Guest: Object {


    @objc dynamic var id: Int = 0
    @objc dynamic var senderId: String = ""
    @objc dynamic var fcmId: String = ""
    @objc dynamic var lat: Double = 0
    @objc dynamic var lng: Double = 0
    @objc dynamic var last_activity: String = ""
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}


extension Guest{
    
    
    static func getInstance() -> Guest? {
        
        let realm = try! Realm()
        let guest = realm.objects(Guest.self).first
        
        if let g = guest {
            return g
        }
        
        return nil
    }
    
    
    static func saveGuest(guest: Guest?) {
        
        if let g = guest {
            
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(g,update: true)
            try! realm.commitWrite()
            
            LocalData.setValue(key: "guest_id", value: g.id)
            
        }
        
    }
    
    static func isStored() -> Bool {
        
        let realm = try! Realm()
        let guest = realm.objects(Guest.self).first
        
        if guest != nil {
            return true
        }
        
        return false
    }
    
    
}
