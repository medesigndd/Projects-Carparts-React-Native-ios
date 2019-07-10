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

class ReviewParser: Parser {
    
    
    func parse() -> [Review] {
        
        var list = [Review]()
        
        if let myResult = self.result {
            
            
            for (_, value) in myResult {
                
                let object = value
                
                Utils.printDebug("\(String(describing: object))")
                let myObject = Review()
                
               
                
                
                myObject.id_rate = object["id"].intValue
                myObject.store_id = object["store_id"].intValue
                myObject.pseudo = object["pseudo"].stringValue
                myObject.rate = object["rate"].doubleValue
                myObject.review = object["review"].stringValue
                myObject.guest_id = object["guest_id"].intValue
                myObject.image = object["image"].stringValue
                
                
                
                list.append(myObject)
            }
            
            
            return list
        }
        
        return []
    }
    
}

