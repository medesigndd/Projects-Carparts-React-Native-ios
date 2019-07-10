//
//  UserParser.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

//
//  JobParser.swift
//  AppTest
//
//  Created by Amine on 5/15/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class DiscussionParser: Parser {
    
    
    func parse() -> [Discussion] {
        
        var list = [Discussion]()
        
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
               
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    let myObject = Discussion()
                    
                    myObject.id = object["id_discussion"].intValue
                    
                    //get sender
                    
                    let sendercontent = object["sender"].stringValue
                    let userParser = UserParser(content: sendercontent)
                    
                   
                    
                    if userParser.success == 1  {
                       
                        let users = userParser.parse()
                        if users.count > 0 {
                            myObject.senderUser = users[0]
                        }
                    }
                    
                    
                    
                    //get last messages
                    let mcontent = object["messages"].stringValue
                    let messageParser = MessageParser(content: mcontent)
                    let messages = messageParser.parse()
                    let listMessages: List<Message> = List<Message>()
                    for el in messages {
                        listMessages.append(el)
                    }
                    myObject.messages = listMessages
                    /////////////////////
                    
                  
                    myObject.nbrMessages = object["nbrMessageNotSeen"].intValue
                    myObject.createdAt = object["created_at"].stringValue
                    myObject.status = object["status"].intValue
                    
                   
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
    
}
