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

class OfferParser: Parser {
    
    
    func parse() -> [Offer] {
        
        var list = [Offer]()
        
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    
                   
                    let myObject = Offer()
                    
                    myObject.id = object["id_offer"].intValue
                    myObject.name = object["name"].stringValue
                    
                    myObject.date_start = object["date_start"].stringValue
                    myObject.date_end = object["date_end"].stringValue
                    
                    myObject.status = object["status"].intValue
                    
                    myObject.store_id = object["store_id"].intValue
                    myObject.store_name = object["store_name"].stringValue
                    
                    
                    myObject.lat = object["latitude"].doubleValue
                    myObject.lng = object["longitude"].doubleValue
                    
                   
                     myObject.distance = object["distance"].doubleValue
                    
                     myObject.user_id = object["user_id"].intValue
                    
                    myObject.featured = object["featured"].intValue
                    
                    let ocontent = object["content"].stringValue
                   
                   
                    
                    let offerContentParser = OfferContentParser(content: ocontent)
                    let offerContent = offerContentParser.parse(id: myObject.id)
                    myObject.content = offerContent
                    
                    
                    
                    
                    
                    let icontent = object["image"]
                    let imageParser = ImagesParser(json: icontent)
                    let image = imageParser.parseSingle()
                    myObject.images = image
                    
                    
                    
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
    
}
