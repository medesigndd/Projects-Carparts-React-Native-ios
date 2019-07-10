//
//  Message.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Message: Object {
    
    @objc dynamic var messageid: Int = 0
    @objc dynamic var message: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var type: Int = Values.SENDER_VIEW
    @objc dynamic var status: Int = Values.NEW
    @objc dynamic var discussionId: Int = 0
    @objc dynamic var senderId: Int = 0
    @objc dynamic var receiver_id: Int = 0

    override static func primaryKey() -> String? {
        return "messageid"
    }
    
    enum Values {
        
        //FROM
        static let SENDER_VIEW: Int     = 0
        static let RECEIVER_VIEW: Int    = 1
        static let LOADING_VIEW: Int    = -1
        
        
        //status value
        static let ERROR: Int = -2
        static let NEW: Int  = -1
        static let LOADED: Int = 0
        static let VIEWD: Int = 1
        static let SENT: Int  = 2
        static let NO_SENT: Int  = 3
        
    }
    
    enum Tags{
        static let TAG_MESSAGE_ID = "messageid"
        static let TAG_ID_DISCUSSION = "discussionid"
        static let TAG_SENDER_ID = "senderid"
        static let TAG_RECEIVER_ID = "receiverid"
        
        
        static let TAG_SENDER_UID = "senderuserid"
        static let TAG_RECEIVER_UID = "receiveruserid"
        
        static let TAG_MESSAGE = "message"
        static let TAG_MESSAGES = "messages"
        static let TAG_DATE = "date_added"
        static let TAG_STATUS = "status"
        static let TAG_TYPE = "type"
        
        
        
        
    }
    
}


class MessengerCache: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var user_id: Int = 0
    @objc dynamic var client_id: Int = 0
    @objc dynamic var page: Int = 0
    @objc dynamic var count: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    func save(){
        
        let realm = try! Realm()
        
        realm.beginWrite()
        realm.add(self,update: true)
        try! realm.commitWrite()
        
    }
    
    static func removeAll() {
        
        let realm = try! Realm()
        
        let result: Results<MessengerCache> = realm.objects(MessengerCache.self)
        
        realm.beginWrite()
        realm.delete(result)
        try! realm.commitWrite()
    }
    
    
    static func getCache(userId: Int,clientId: Int) -> MessengerCache? {
        
    
        let realm = try! Realm()
        let result = realm.objects(MessengerCache.self).filter("user_id == \(userId) AND client_id == \(clientId)")
        
        
        if let mcache = result.first {
    
            return mcache
        }
        
        return nil
    }
    
    
    
}

extension Message{
    
    func validate(sessId: Int) {
        
        if self.senderId == sessId{
            self.type = Message.Values.SENDER_VIEW
        }else{
            self.type = Message.Values.RECEIVER_VIEW
        }
        
    }
    
    func save() {
        
        if self.messageid > 0 {
            
            let message = self
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(message,update: true)
            try! realm.commitWrite()
            
            
        }
    }
    
    static func findByDiscussion(userId: Int,clientId: Int) -> [Message] {
        
        let realm = try! Realm()
        
        let messages = realm.objects(Message.self).filter(" (receiver_id = \(userId) AND senderId = \(clientId) ) OR   (receiver_id = \(clientId) AND senderId = \(userId) )").sorted(byKeyPath: "messageid",ascending: false)
        
        var list: [Message] = []
        
        for message in messages {
            list.append(message)
        }
        
        return list
        
    }
    
    static func getLastMessageId(client_id: Int) -> Int {
        
        let realm = try! Realm()
        
        let message = realm.objects(Message.self).filter("receiver_id == \(client_id)").sorted(byKeyPath: "messageid",ascending: false)
        
       
        if let msg = message.first {
            return msg.messageid
        }
        
        return -1
        
    }
    
    
    
    static func removeAll() {
        
        let realm = try! Realm()
        
        let messages: Results<Message> = realm.objects(Message.self)
        
        realm.beginWrite()
        realm.delete(messages)
        try! realm.commitWrite()
    }
    
}

extension Array where Element:Message {
    
    func validateAll(sessId: Int){
        
        let messages: [Message] = self
        
        if messages.count > 0 {
            
            for message in messages {
                message.validate(sessId: sessId)
            }
            
        }
        
    }
    
    func convert() -> List<Message> {
        
        let messages: [Message] = self
        let list: List<Message> = List<Message>()
        
        for message in messages {
            list.append(message)
        }
        
        return list
    }
    
    func saveAll(){
        
        let messages: [Message] = self
        
        if messages.count > 0 {
            
            let realm = try! Realm()
            
            realm.beginWrite()
            realm.add(messages,update: true)
            try! realm.commitWrite()
            
        }
        
    }
    
    
    func refresh(messageId: Int,status: Int) -> [Message] {
        
        let messages = self
        
        var size = messages.count
        
        if size > 0 {
            size = size - 1
        }
        
        for index in 0...size {
            if messages[index].messageid == messageId {
                messages[index].status = status
            }
        }
        
        return messages
        
    }
    
    
 
   
}



