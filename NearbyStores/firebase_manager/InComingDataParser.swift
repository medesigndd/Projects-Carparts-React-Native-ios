//
//  InComingDataParser.swift
//  NearbyStores
//
//  Created by Amine on 6/23/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftEventBus

class InComingDataParser {
    
    private var json:JSON? = nil
    private var data: [String: String]? = nil
    
    
    static let tag_new_message = "newMessage"
   

    
    init(content: String?) {
        if let string = content {
            self.convertToJSON(content: string)
        }
    }
    
    
    func convertToJSON(content: String) {
        
        if let dataFromString = content.data(using: .utf8, allowLossyConversion: false) {
            
            do {
                self.json = try JSON(data: dataFromString)
            } catch {
                Utils.printDebug(error.localizedDescription)
            }
            
        }
        
    }
    
    
    func proccess()   {
        
        if let json = self.json {
            
            if let type = json["type"].string {
                
                if type == Tags.NOTIFICATION && AppConfig.CHAT_ENABLED == true {
                    
                    let dataJson = json["data"].stringValue
                   
                    let message = MessageParser(content: dataJson)

                    if message.success == 1 {
                        
                        let messages = message.parse()
                        
                        
                        let state  = UIApplication.shared.applicationState
                        switch state {
                        case UIApplicationState.active:
                            
                            if let value = LocalData.getValue(key: Settings.Keys.MESSENGER_NOTIFICATION){
                                if value == false{
                                    return
                                }
                            }
                            
                            if  messages.count > 0 {
                                SwiftEventBus.post("on_receive_message", sender: messages[0])
                            }
                            
                            break
                        case UIApplicationState.background:
                            
                            if  messages.count > 0 {
                                
                                messages[0].save()
                                
                                Messenger.nbrMessagesNotSeen += 1
                                
                                if Messenger.nbrMessagesNotSeen == 1 {
                                    
                                        if let value = LocalData.getValue(key: Settings.Keys.MESSENGER_NOTIFICATION){
                                            if value == false{
                                                return
                                            }
                                        }
                                    
                                        NotificationManager.push(
                                            title: "New Message".localized,
                                            subtitle: messages[0].message,
                                            identifier: InComingDataParser.tag_new_message
                                        )
                                 
                                    
                                }else if Messenger.nbrMessagesNotSeen > 1 &&  Messenger.nbrMessagesNotSeen < 5{
                                    
                                        if let value = LocalData.getValue(key: Settings.Keys.MESSENGER_NOTIFICATION){
                                            if value == false{
                                                return
                                            }
                                        }
                                    
                                        NotificationManager.push(
                                            title: AppConfig.APP_NAME,
                                            subtitle: "You have \(Messenger.nbrMessagesNotSeen) messages",
                                            identifier: InComingDataParser.tag_new_message
                                        )
                                    
                                }
                                
                            }
                            
                            break
                        case .inactive:
                            
                            
                            if  messages.count > 0 {
                                
                                messages[0].save()
                                
                                Messenger.nbrMessagesNotSeen += 1
                                
                                if Messenger.nbrMessagesNotSeen == 1 {
                                    
                                    if let value = LocalData.getValue(key: Settings.Keys.MESSENGER_NOTIFICATION){
                                        if value == false{
                                            return
                                        }
                                    }
                                    
                                    
                                    NotificationManager.push(
                                        title: "New Message".localized,
                                        subtitle: messages[0].message,
                                        identifier: InComingDataParser.tag_new_message
                                    )
                                    
                                }else if Messenger.nbrMessagesNotSeen > 1 &&  Messenger.nbrMessagesNotSeen < 5{
                                    
                                    if let value = LocalData.getValue(key: Settings.Keys.MESSENGER_NOTIFICATION){
                                        if value == false{
                                            return
                                        }
                                    }
                                    
                                    NotificationManager.push(
                                        title: AppConfig.APP_NAME,
                                        subtitle: "You have \(Messenger.nbrMessagesNotSeen) messages",
                                        identifier: InComingDataParser.tag_new_message
                                    )
                                    
                                }
                                
                            }
                            
                            break
                        }
                        
                    }
                    
                }else if type == Tags.CAMPAIGN{
                    
                    let dataJson = json["data"]
                    let parser = CampaignParser(data: dataJson)
                    parser.parse()
                    
                    if let cid = parser.cid {
                      //  CampagneController.markReceive(cid);
                        let loader = SimpleLoader()
                        loader.run(url: Constances.Api.API_MARK_RECEIVE, parameters: [
                            "cid": cid
                            ], compilation: {parser in
                               
                        })
                    }
                    
                    
                    if let type = parser.type, let cid =  parser.cid {
                        
                     
                        let parameters = [
                            "cid":  String(describing: cid)
                        ]
                        
                        let api = SimpleLoader()
                        api.run(url: Constances.Api.API_MARK_RECEIVE, parameters: parameters, compilation: { (parser) in
                            
                            if let p = parser{
                                if p.success == 1{
                                    
                                }
                            }
                        })
                        
                        //push user notification when the app running in the background
                        if type == CampaignParser.OFFER {
                            
                            
                            if let value = LocalData.getValue(key: Settings.Keys.OFFERS_NOTIFICATION){
                                if value == false{
                                    return
                                }
                            }
                            
                            NotificationManager.last_received_oid = parser.id
                            NotificationManager.last_received_cid = parser.cid
                            NotificationManager.last_received_type =  CampaignParser.OFFER
                        
                            if let body = parser.body, let attachment = body.attachement  {
                                
                                if attachment != ""{
                                    
                                     NotificationManager.push(title: parser.title!, subtitle: parser.sub_title!, attachement: attachment, identifier: CampaignParser.OFFER)
                                    
                                    return
                                }else if parser.image != "" {
                                    
                                    NotificationManager.push(title: parser.title!, subtitle: parser.sub_title!, attachement: parser.image!, identifier: CampaignParser.OFFER)
                                    
                                    return
                                }
                               
                                
                            }
                            
                            NotificationManager.push(title: parser.title!,
                                                     subtitle: parser.sub_title!, identifier: CampaignParser.OFFER)
                            
                          
                        }else if type == CampaignParser.STORE {
                            
                            if let value = LocalData.getValue(key: Settings.Keys.STORES_NOTIFICATION){
                                if value == false{
                                    return
                                }
                            }
                            
                            NotificationManager.last_received_oid = parser.id
                            NotificationManager.last_received_cid = parser.cid
                            NotificationManager.last_received_type =  CampaignParser.STORE
                            
                           
                            if parser.image != "" {
                                
                                NotificationManager.push(title: parser.title!, subtitle: parser.sub_title!, attachement: parser.image!, identifier: CampaignParser.OFFER)
                                
                                return
                            }
                            
                            NotificationManager.push(title: parser.title!,
                                                     subtitle: parser.sub_title!, identifier: CampaignParser.STORE)
                            
                            
                        }else if type == CampaignParser.EVENT {
                            
                            
                            if let value = LocalData.getValue(key: Settings.Keys.EVENTS_NOTIFICATION){
                                if value == false{
                                    return
                                }
                            }
                            
                            NotificationManager.last_received_oid = parser.id
                            NotificationManager.last_received_cid = parser.cid
                            NotificationManager.last_received_type =  CampaignParser.STORE
                            
                            if parser.image != "" {
                                
                                NotificationManager.push(title: parser.title!, subtitle: parser.sub_title!, attachement: parser.image!, identifier: CampaignParser.OFFER)
                                
                                return
                            }
                            
                            NotificationManager.push(title: parser.title!,
                                                     subtitle: parser.sub_title!, identifier: CampaignParser.STORE)
                            
                        }
                        
                        
                    }
                    
                    
                }
                
            }
            
        
        }
        
    }
    
   
    
    struct Tags {
        
        static let CAMPAIGN: String = "campaign";
        static let NOTIFICATION: String = "notification";
        
        static let TITLE: String = "title";
        static let SUB_TITLE: String = "sub-title";
        static let BODY: String = "body";
        static let ID: String = "id";
        static let IMAGE: String = "image";
        static let TYPE: String = "type";
        static let CAMPAGNE_ID: String = "cid";
        
        static let OFFER_PRICE: String = "price";
        static let OFFER_PERCENT: String = "percent";
        static let OFFER_DESCRIPTION: String = "description";
        static let OFFER_ATTACHMENT: String = "attachment";
        static let OFFER_CURRENCY: String = "currency";
        static let OFFER_STORE_NAME: String = "store_name";
        
    }
    
    
    
    static func openViewEventBus(controller: UIViewController){
        
        SwiftEventBus.onMainThread(self, name: "open_view_"+CampaignParser.STORE) { result in
            
            if let data = result?.object{
                
                let list:[String: Int] = data as! [String : Int]
                if let id = list["oid"]{
                    let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
                    if sb.instantiateInitialViewController() != nil {
                        
                        let ms: StoreDetailViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailViewController
                        ms.storeId = id
                        
                        controller.present(ms, animated: true)
                    }
                }
                
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: "open_view_"+CampaignParser.OFFER) { result in
            
            if let data = result?.object{
                
                let list:[String: Int] = data as! [String : Int]
                if let id = list["oid"]{
                    let sb = UIStoryboard(name: "OfferDetail", bundle: nil)
                    if sb.instantiateInitialViewController() != nil {
                        
                        let ms: OfferDetailViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailViewController
                        
                        ms.offer_id = id
                        
                        controller.present(ms, animated: true)
                    }
                }
                
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: "open_view_"+CampaignParser.EVENT) { result in
            
            if let data = result?.object{
                
                let list:[String: Int] = data as! [String : Int]
                if let id = list["oid"]{
                    let sb = UIStoryboard(name: "EventDetail", bundle: nil)
                    if sb.instantiateInitialViewController() != nil {
                        
                        let ms: EventDetailViewController = sb.instantiateViewController(withIdentifier: "eventdetailVC") as! EventDetailViewController
                        
                        ms.event_id = id
                        
                        controller.present(ms, animated: true)
                    }
                }
                
            }
            
        }
        
    }
    
    
    
}







