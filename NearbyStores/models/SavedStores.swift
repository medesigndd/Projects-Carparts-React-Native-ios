//
//  SavedStores.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class SavedStores: Object {
    
  
    @objc dynamic var id: Int = 1
    var listID: List<Int> = List<Int>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    

}

extension SavedStores{
    
    
    func getListAsString() -> String {
        
        let savedStore = self
        let list = savedStore.listID
            
        var string = ""
        for id in list{
            string = "\(string)\(id)"
            string = "\(string),"
        }
        
        return string
    }
    
    static func exist(id: Int) -> Bool {
        
        if let savedStore = SavedStores.getInstance(){
            
            
            let size = savedStore.listID.count-1
            
            if size>=0{
                for index in 0...size{
                    if savedStore.listID[index] == id {
                        return true
                    }
                }
            }
            
        
            
        }
        
        return false
    }
    
    static func remove(id: Int) {
        
        if let savedStore = SavedStores.getInstance(){
            
            
            if savedStore.listID.count>0{
                let size = savedStore.listID.count-1
                for index in 0...size{
                    if savedStore.listID[index] == id {
                        
                        let realm = try! Realm()
                        realm.beginWrite()
                        savedStore.listID.remove(at: index)
                        try! realm.commitWrite()
                        
                    }
                }
            }
            
            
            savedStore.save()
            
        }else{
            
            let savedStore = SavedStores()
            savedStore.id = 1
            savedStore.listID.append(id)
            savedStore.save()
            
        }
        
    }
    
    static func save(id: Int) {
        
        if let savedStore = SavedStores.getInstance(){
            
            if savedStore.listID.count>0{
                
                let size = savedStore.listID.count-1
                for index in 0...size{
                    if savedStore.listID[index] == id {
                        return
                    }
                }
            }
            
            
            let realm = try! Realm()
            realm.beginWrite()
            savedStore.listID.append(id)
            try! realm.commitWrite()
            
            savedStore.save()
            
        }else{
            
            if let guest = Guest.getInstance(){
                let savedStore = SavedStores()
                savedStore.id = guest.id
                savedStore.listID = List<Int>()
                savedStore.listID.append(id)
                savedStore.save()
            }
            
        }
        
    }
    
    func save() {
        
        let savedStore = self
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(savedStore,update: true)
        try! realm.commitWrite()
    }
    
    static func getInstance() -> SavedStores? {
        
        if let guest = Guest.getInstance(){
            
            let realm = try! Realm()
            let object = realm.objects(SavedStores.self).filter("id == \(guest.id)").first
            
            if let obj = object {
                return obj
            }
        }
        
        
        return nil
    }
    
}
