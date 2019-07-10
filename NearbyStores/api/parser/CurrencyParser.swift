//
//  CurrencyParser.swift
//  NearbyStores
//
//  Created by Amine on 6/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class CurrencyParser: Parser {

    func parse() -> Currency? {
        
        if let object = self.json {
            
            let myObject = Currency()
            
            myObject.code = object["code"].stringValue
            myObject.symbol = object["symbol"].stringValue
            myObject.name = object["name"].stringValue
            myObject.format = object["format"].intValue
            
            return myObject
        }
        
        return nil
    }
}
