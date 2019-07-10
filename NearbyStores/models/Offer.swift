//
//  Offer.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Offer: Object {
    

    @objc dynamic var id: Int = 0
    @objc dynamic var content: OfferContent? = nil
    @objc dynamic var store_id: Int = 0
    @objc dynamic var user_id: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var date_start: String = ""
    @objc dynamic var date_end: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var store_name: String = ""
    @objc dynamic var images: Images? = nil
    @objc dynamic var distance: Double = 0
    @objc dynamic var lat: Double = 0
    @objc dynamic var lng: Double = 0
    @objc dynamic var featured: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}


extension Offer{
    
    func save() {
        if self.id > 0 {
            
            let offer = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(offer,update: true)
            try! realm.commitWrite()
            
        }
    }
    
    static func findById(id: Int) -> Offer? {
        
        let realm = try! Realm()
        
        if let offer = realm.objects(Offer.self).filter("id == \(id)").first {
            return offer
        }
        
        return nil
    }
}


