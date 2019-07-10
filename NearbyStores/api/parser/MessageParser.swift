//
//  MessageParser.swift
//  NearbyStores
//
//  Created by Amine on 6/13/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftyJSON

class MessageParser: Parser {
    
    var messageId:Int? = nil
    
    override init(content: String) {
        super.init(content: content)
    }
    
    init(content: String,withMessageId: Bool) {
        super.init(content: content)
        
        if let id = self.json!["messageId"].int {
             self.messageId = id
        }else{
             self.messageId = self.json!["messageId"].intValue
        }
        
      
    }

    func parse() -> [Message] {
        
        var list = [Message]()
        
        if let myResult = self.result {
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    

                    let myObject = Message()
                    
                    
                    myObject.messageid = object["id_message"].intValue
                    myObject.discussionId = object["discussion_id"].intValue
                    myObject.date = object["created_at"].stringValue
                    myObject.message = object["content"].stringValue
                    myObject.status = object["status"].intValue
                    myObject.type = Message.Values.RECEIVER_VIEW
                    
                    myObject.senderId = object["sender_id"].intValue
                    myObject.receiver_id = object["receiver_id"].intValue
                    
                    
                    
                    list.append(myObject)
                }
                
            }
            
            
            
            return list
        }
        
        return []
    }
}
