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

class EventParser: Parser {
    
    
    func parse() -> [Event] {
        
        var list = [Event]()
        
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    let myObject = Event()
                    
                    myObject.id = object["id_event"].intValue
                    myObject.name = object["name"].stringValue
                    myObject.address = object["address"].stringValue
                    
                   
                    myObject.lat = object["lat"].doubleValue
                    myObject.lng = object["lng"].doubleValue
                    myObject.distance = object["distance"].doubleValue
                    
                    myObject.status = object["status"].intValue
                    
                    myObject.store_name = object["store_name"].stringValue
                    myObject.store_id = object["store_id"].intValue
                    
                    
                    myObject.tel = object["tel"].stringValue
                    myObject.dateBegin = object["date_b"].stringValue
                    myObject.dateEnd = object["date_e"].stringValue
                    myObject.desc = object["description"].stringValue
                    myObject.webSite = object["website"].stringValue
                    
                    myObject.featured = object["featured"].intValue
                   
                                
                    
                    let icontent = object["images"]
                    let imageParser = ImagesParser(json: icontent)
                    let images = imageParser.parse()
                    let listImages: List<Images> = List<Images>()
                    for el in images {
                        listImages.append(el)
                    }
                    
                    myObject.listImages = listImages
                  
                    
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
    
}
