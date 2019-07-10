//
//  Discussion.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Discussion: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var senderUser: User? = nil
    @objc dynamic var receiverId: Int = 0
    var messages: List<Message> = List<Message>()
    @objc dynamic var createdAt: String = ""
    @objc dynamic var nbrMessages: Int = 0
    @objc dynamic var status: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    

    enum Tags {
        static let ID_DISC: String  = "discussion_id"
        static let SENDER_ID: String  = "sender_userid"
        static let RECEIVER_ID  = "receiver_userid"
    }
    
    
   
   
    
}

extension Discussion{
    
    func save()  {
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(self,update: true)
        try! realm.commitWrite()
    }
    
    
    static func getById(id: Int) -> Discussion? {
        
        let realm = try! Realm()
        
        if let discussion = realm.objects(Discussion.self).filter("id == \(id)").first {
            return discussion
        }
        
        return nil
    }
    
    
    
}

extension Array where Element:Discussion {
    
    func saveAll(){
        
        let discussions: [Discussion] = self
        
        if discussions.count > 0 {
            
            let realm = try! Realm()
            
            realm.beginWrite()
            realm.add(discussions,update: true)
            try! realm.commitWrite()
            
        }
        
    }
    
    func refreshToTop(client_id: Int) -> [Discussion] {
        
        var discussions: [Discussion] = self
        
        
        //resfresh item to the top
        for index in 0...discussions.count {
            
            if discussions[index].senderUser?.id == client_id{
                
                
                let discussion = discussions[index]
                 discussions.remove(at: index)
                
                var newList: [Discussion] = []
                
                newList.append(discussion)
                
                newList += discussions
                discussions = newList
                
                break
            }
            
        }
        
        return discussions
        
    }
    
    func getCurrentIndex(client_id: Int) -> Int? {
        
        var discussions: [Discussion] = self
        
        
        //resfresh item to the top
        let size = discussions.count - 1
        
        if size >= 0 {
            
            for index in 0...size {
                
                if discussions[index].senderUser?.id == client_id{
                    return index
                }
                
            }
            
        }
        
        
        return nil
        
    }
  
}









