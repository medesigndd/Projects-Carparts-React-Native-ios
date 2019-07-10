//
//  CampaignParser.swift
//  NearbyStores
//
//  Created by Amine on 6/23/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftyJSON

class CampaignParser {
    
    var data:JSON? = nil
    
    static let STORE: String = "store"
    static let OFFER: String = "offer"
    static let EVENT: String = "event"
    static let MESSAGE: String = "message"
    

    var type: String? = nil
    var id:Int? = nil
    var title: String? = nil
    var sub_title: String? = nil
    var image: String? = nil
    var body: BodyCampaignParser? = nil
    var cid: Int? = nil

    init(data: JSON) {
        self.data = data
    }
    
    func parse() {
        
        if let data = self.data {
            
            self.id = data[InComingDataParser.Tags.ID].intValue
            self.type = data[InComingDataParser.Tags.TYPE].stringValue
            self.title = data[InComingDataParser.Tags.TITLE].stringValue
            self.sub_title = data[InComingDataParser.Tags.SUB_TITLE].stringValue
            
            self.image =  data[InComingDataParser.Tags.IMAGE].stringValue
            self.cid = data[InComingDataParser.Tags.CAMPAGNE_ID].intValue
            
             let body  = data[InComingDataParser.Tags.BODY]
            
            if  self.type == CampaignParser.OFFER {
                
                self.body = BodyCampaignParser(json: body)
                self.body?.parse()
            
                
            }
            
        }
 
    }
    
}


class BodyCampaignParser {

    var json: JSON? = nil
    
    var price: Double? = nil
    var percent: Double? = nil
    var currency: String? = nil
    var description: String? = nil
    var attachement: String? = nil
    var storeName: String? = nil
   
    
    init(json: JSON) {
        self.json = json
    }
    
    func parse()  {
        
        if let json = self.json {
            
            self.price = json[InComingDataParser.Tags.OFFER_PRICE].doubleValue
            self.percent = json[InComingDataParser.Tags.OFFER_PERCENT].doubleValue
            self.currency = json[InComingDataParser.Tags.OFFER_CURRENCY].stringValue
            self.description = json[InComingDataParser.Tags.OFFER_DESCRIPTION].stringValue
            self.attachement = json[InComingDataParser.Tags.OFFER_ATTACHMENT].stringValue
            self.storeName = json[InComingDataParser.Tags.OFFER_STORE_NAME].stringValue
            
        }
        
    }
    
    
    
}


