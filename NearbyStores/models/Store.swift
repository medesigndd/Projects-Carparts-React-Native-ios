//
//  Store.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Store: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var distance: Double = 0
    @objc dynamic var desc: String = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var status: Int = 0
    @objc dynamic var detail: String = ""
    @objc dynamic var user: User? = nil
    @objc dynamic var user_id: Int = 0
    @objc dynamic var imageJson: String = ""
    @objc dynamic var voted: Bool = false
    @objc dynamic var votes: Double = 0
    @objc dynamic var nbr_votes: String = ""
    var listImages: List<Images> = List<Images>()
    @objc dynamic var phone: String = ""
    @objc dynamic var saved: Bool=false
    @objc dynamic var nbrOffers: Int = 0
    @objc dynamic var lastOffer: String = ""
    @objc dynamic var category_id: Int = 0
    @objc dynamic var featured: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Store{
    
    func save() {
        if self.id > 0 {
            let store = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(store,update: true)
            try! realm.commitWrite()
            
        }
    }
    
    static func findById(id: Int) -> Store? {
        
        let realm = try! Realm()
        
        if let store = realm.objects(Store.self).filter("id == \(id)").first {
            return store
        }
        
        return nil
    }
}


struct Distance {
    
    enum Types  {
        static let Kilometers = "KM"
        static let Miles = "Miles"
        static let Meters = "M"
        static let Feets = "feet"
    }
    
    init(distance: Double) {
        self.distanceMeter = distance
    }
    var distanceKM: Int {
        get {
            if let m = distanceMeter {
                return Int(m/1000)
            }
            return 0
        }
    }
    var distanceMILE: Double {
        get {
            if let m = distanceMeter {
                return Double(m/0.000621371)
            }
            return 0
        }
    }
    var distanceMeter: Double? = nil
    
    func getCurrent(type: String) -> String {
        
        if type == Distance.Types.Kilometers {
            
            if Int(distanceMeter!) > 1000 {
                return "\(distanceKM) \(type.localized)"
            }else{
                return "\(Int(distanceMeter!)) \(Distance.Types.Meters.localized)"
            }
            
        }else if type == Distance.Types.Meters {
            
            return "\(String(describing: distanceMeter)) \(type.localized)"
            
        }else if type == Distance.Types.Miles {
            
            return "\(distanceMILE) \(type.localized)"
            
        }
        
        return "\(String(describing: distanceMeter)) \(Distance.Types.Meters)"
    }
    
}


extension Double {
    
    func calculeDistance() -> Distance {
        
        return Distance(distance: self)
    }
    
}







