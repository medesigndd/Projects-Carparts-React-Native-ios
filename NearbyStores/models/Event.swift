//
//  Event.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Event: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var address: String = ""
    var listImages: List<Images> = List<Images>()
    @objc dynamic var imageJson: String = ""
    @objc dynamic var dateBegin: String = ""
    @objc dynamic var dateEnd: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var distance: Double = 0
    @objc dynamic var lat: Double = 0
    @objc dynamic var lng: Double = 0
    @objc dynamic var tel: String = ""
    @objc dynamic var webSite: String = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var liked: Bool = false
    @objc dynamic var store_id: Int = 0
    @objc dynamic var store_name: String = ""
    @objc dynamic var featured: Int = 0
    
    
    override static func primaryKey() -> String? {
        return "id"
    }

}

extension Event{
    func save() {
        if self.id > 0 {
            
            let event = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(event,update: true)
            try! realm.commitWrite()
            
        }
    }
    
    static func findById(id: Int) -> Event? {
        
        let realm = try! Realm()
        
        if let event = realm.objects(Event.self).filter("id == \(id)").first {
            return event
        }
        
        return nil
    }
}
