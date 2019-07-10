//
//  UserParser.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

//
//  Created by Amine on 5/15/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class GuestParser: Parser {
    
    
    func parse() -> [Guest] {
        
        var list = [Guest]()
        
        if let myResult = self.result {
            
            
            for (_, value) in myResult {
                
                let object = value
                
                Utils.printDebug("\(String(describing: object))")
                let myObject = Guest()
                
                
            
                myObject.id = object["id"].intValue
                myObject.senderId = object["sender_id"].stringValue
                myObject.fcmId = object["fcm_id"].stringValue
                myObject.lat = object["lat"].doubleValue
                myObject.lng = object["lng"].doubleValue
                
               
                list.append(myObject)
            }
            
            
            return list
        }
        
        return []
    }
    
}

