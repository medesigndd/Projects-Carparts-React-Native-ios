//
//  UpComingEvents.swift
//  NearbyStores
//
//  Created by Amine on 7/19/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class UpComingEvent: Object  {

    @objc dynamic var event_id: Int = 0
    @objc dynamic var event_name: String = ""
    @objc dynamic var begin_at: String = ""
    @objc dynamic var notified: Bool = false
    
    override static func primaryKey() -> String? {
        return "event_id"
    }
 
    
}

extension UpComingEvent{
    
    
    static func getListAsString() -> String? {
        
       let list = UpComingEvent.getUpComingEventsID()
        
        var string: String? = nil
        
        if list.count > 0{
            string = ""
            for id in list{
                string = "\(string!)\(id),"
            }
        }
        
        
        return string
    }
    
    static func getList() -> [UpComingEvent]{
        
        let realm = try! Realm()
        let objects = realm.objects(UpComingEvent.self)
        
        var list:[UpComingEvent] = []
        
        for upe in objects{
            list.append(upe)
        }
        
        return list
    }
    
    
    static func getUpComingEventsID() -> [Int]{
        let realm = try! Realm()
        let objects = realm.objects(UpComingEvent.self)
        
        var list:[Int] = []
        
        
        for obj in objects{
            if DateUtils.isLessThan24(dateUTC: obj.begin_at) == true{
                list.append(obj.event_id)
            }
        }
        
        return list
    }
    
    static func getUpComingEventsNotNotified() -> [UpComingEvent]{
        
        let realm = try! Realm()
        let objects = realm.objects(UpComingEvent.self).filter("notified == \(false)")
        
        var list:[UpComingEvent] = []
        
        for obj in objects{
            if DateUtils.isLessThan24(dateUTC: obj.begin_at) == true{
                list.append(obj)
            }
        }
        
        return list
    }
    
    static func getUpComingEvents() -> [UpComingEvent]{
        let realm = try! Realm()
        let objects = realm.objects(UpComingEvent.self)
        
        var list:[UpComingEvent] = []
        
        
        for obj in objects{
            if DateUtils.isLessThan24(dateUTC: obj.begin_at) == true{
                list.append(obj)
            }
        }
        
        return list
    }
    
    static func save(event_id: Int, event_name: String, begin_at: String){
        
        let realm = try! Realm()
        
        let upe = UpComingEvent()
        upe.event_id = event_id
        upe.event_name = event_name
        upe.begin_at = begin_at
       
        realm.beginWrite()
        realm.add(upe, update: true)
        try! realm.commitWrite()
        
    }
    
    
    static func remove(event_id: Int){
        
        let realm = try! Realm()
        
        if let upe = realm.objects(UpComingEvent.self).filter("event_id == \(event_id)").first{
            realm.beginWrite()
            realm.delete(upe)
            try! realm.commitWrite()
        }
        
    }
    
    static func notified(){
        
        let realm = try! Realm()
        let objects = realm.objects(UpComingEvent.self).filter("notified == \(false)")
        for obj in objects{
            if DateUtils.isLessThan24(dateUTC: obj.begin_at){
                realm.beginWrite()
                obj.notified = true
                realm.add(obj, update: true)
                try! realm.commitWrite()
            }
        }
        
    }
    
    
}
