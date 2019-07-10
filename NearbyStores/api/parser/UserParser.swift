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

class UserParser: Parser {
    

    
    func parse() -> [User] {
        
        var list = [User]()
        
        if let myResult = self.result {
            
            
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    
                    
                    let myObject = User()
                    
                    myObject.id = object["id_user"].intValue
                    myObject.name = object["name"].stringValue
                   
                    myObject.email = object["email"].stringValue
                    
                    
                    myObject.status = object["status"].intValue
                    myObject.distance = object["distance"].doubleValue
                    
                    
                    
                    myObject.latitude = object["lat"].doubleValue
                    myObject.longitude = object["lng"].doubleValue
                    
                    
                    
                    myObject.username = object["username"].stringValue
                    
                   
                    myObject.phone = object["telephone"].stringValue
                    myObject.senderid = object["senderid"].stringValue
                    myObject.auth = object["typeAuth"].stringValue
                    myObject.country = object["country_name"].stringValue
                    myObject.blocked = object["blocked"].boolValue
                    
                    myObject.job = object["job"].stringValue
                    
                    if object["is_online"].intValue == 1 {
                         myObject.online = true
                    }else{
                        myObject.online = false
                    }
                   
                    
                    let icontent = object["images"]
                    let imageParser = ImagesParser(json: icontent)
                    let images = imageParser.parse()
                    
                    if images.count > 0{
                        myObject.images = images[0]
                    }
                    
                    
                    
                    
                    list.append(myObject)
                    
                }
                
            }
            
            return list
        }
        
        return []
    }
    
}
