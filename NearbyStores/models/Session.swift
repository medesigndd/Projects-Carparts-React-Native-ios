//
//  Session.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Session: Object {

    @objc dynamic var sessionId: Int = 1
    @objc dynamic var user: User?

    override static func primaryKey() -> String? {
        return "sessionId"
    }
    
}

extension Session {
    
   
    struct Local {
        
        static func isLogged() -> Bool {
            
            
            if let connected_id = LocalData.getValue(key: "connected_id", defaultValue: 0), connected_id > 0 {
                return true
            }
        
            return false
        }
    }
    
    static func getInstance() -> Session? {
        
        let realm = try! Realm()
        let session = realm.objects(Session.self).first
        
        if let sess = session {
            return sess
        }
        
        return nil
    }
    
    static func isLogged() -> Bool {
        
        let realm = try! Realm()
        
        let sessions = realm.objects(Session.self)
        
        
        guard let session = sessions.first else { return false }
        
    
        if (session.user != nil) {
            return true
        }
        
        return false
    }
    
    static func createSession(user: User?) {
        
        if let u = user {
            
            let session = Session()
            session.sessionId = 1
            session.user = u
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(session,update: true)
            try! realm.commitWrite()
            
       
            LocalData.setValue(key: "connected_id", value: u.id)
            
            
        }
       
    }
    
    static func logout() -> Bool {
        
        let realm = try! Realm()
        
        let session = realm.objects(Session.self).first
        
        if let sess = session {
            
            realm.beginWrite()
            realm.delete(sess)
            try! realm.commitWrite()
            
            LocalData.setValue(key: "connected_id", value: 0)
            
            return true
        }
        
        return false
    }
    
}
