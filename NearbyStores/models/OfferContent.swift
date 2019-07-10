//
//  OfferContent.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class OfferContent: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var desc: String  = ""
    @objc dynamic var price: Float = 0
    @objc dynamic var percent: Float = 0
    @objc dynamic var currency: Currency? = nil

    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class Currency: Object {
    @objc dynamic var code: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var format: Int = 1
}


extension Currency{
    
    //float price,String cData
    func parseCurrencyFormat(price: Float) -> String? {
        
        switch self.format {
        case 1:
            return "\(self.symbol)\(price)"
        case 2:
            return "\(price)\(self.symbol)"
        case 3:
            return "\(self.symbol) \(price)"
        case 4:
            return "\(price) \(self.symbol)"
        case 5:
            return String(price)
        case 6:
            return "\(self.symbol)\(price) \(self.code)"
        case 7:
            return "\(self.code)\(price)"
        case 8:
            return "\(price)\(self.code)"
        default:
            return String(price);
        }
        
        return nil
        
    }
    
    
    
}
