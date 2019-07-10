//
//  SavedStores.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class SavedEvents: Object {
    
    
    @objc dynamic var id: Int = 1
    var listID: List<Int> = List<Int>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}

extension SavedEvents{
    
    
    func getListAsString() -> String {
        
        let savedEvent = self
        let list = savedEvent.listID
        
        var string = ""
        for id in list{
            string = "\(string)\(id)"
            string = "\(string),"
        }
        
        return string
    }
    
    static func exist(id: Int) -> Bool {
        
        if let savedEvent = SavedEvents.getInstance(){
            
            
            let size = savedEvent.listID.count-1
            
            if size>=0{
                for index in 0...size{
                    if savedEvent.listID[index] == id {
                        return true
                    }
                }
            }

        }
        
        return false
    }
    
    static func remove(id: Int) {
        
        if let savedEvent = SavedEvents.getInstance(){
            
            
            if savedEvent.listID.count>0{
                let size = savedEvent.listID.count-1
                
                if size>=0{
                    for index in 0...size{
                        if savedEvent.listID[index] == id {
                            
                            let realm = try! Realm()
                            realm.beginWrite()
                            savedEvent.listID.remove(at: index)
                            try! realm.commitWrite()
                            
                        }
                    }
                }
                
            }
            
            
            savedEvent.save()
            
        }else{
            
            let savedEvent = SavedEvents()
            savedEvent.id = 1
            savedEvent.listID.append(id)
            savedEvent.save()
            
        }
        
    }
    
    static func save(id: Int) {
        
        if let savedEvent = SavedEvents.getInstance(){
            
            if savedEvent.listID.count>0{
                
                let size = savedEvent.listID.count-1
                for index in 0...size{
                    if savedEvent.listID[index] == id {
                        return
                    }
                }
            }
            
            
            let realm = try! Realm()
            realm.beginWrite()
            savedEvent.listID.append(id)
            try! realm.commitWrite()
            
            savedEvent.save()
            
        }else{
            
             if let guest = Guest.getInstance(){
                let savedEvent = SavedEvents()
                savedEvent.id = guest.id
                savedEvent.listID = List<Int>()
                savedEvent.listID.append(id)
                savedEvent.save()
            }
            
        }
        
    }
    
    func save() {
        
        let savedEvent = self
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(savedEvent,update: true)
        try! realm.commitWrite()
    }
    
    static func getInstance() -> SavedEvents? {
        
        if let guest = Guest.getInstance(){
            
            let realm = try! Realm()
            let object = realm.objects(SavedEvents.self).filter("id == \(guest.id)").first
            if let obj = object {
                return obj
            }
            
        }
       
       
        
        return nil
    }
    
}
