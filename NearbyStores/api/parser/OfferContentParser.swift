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
import SwiftyJSON

class OfferContentParser: Parser {
    
    
    func parse(id: Int) -> OfferContent? {
        
        if let object = self.json {
            
            
            let myObject = OfferContent()
            
            
            myObject.id = id
            myObject.desc = object["description"].stringValue
            myObject.percent = object["percent"].floatValue
            myObject.price = object["price"].floatValue
            
            
            if myObject.price != 0 {
                
                let currencyJSON = object["currency"]
                let currencyParser = CurrencyParser(json: currencyJSON)
                
                if let currency = currencyParser.parse() {
                    myObject.currency = currency
                }
              
            }
            
        
            return myObject
        }
        
        return nil
    }
    
}



