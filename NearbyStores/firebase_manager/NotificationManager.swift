//
//  NotificationManager.swift
//  NearbyStores
//
//  Created by Amine on 6/23/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager {
    

    static var last_received_oid: Int? = nil //store, offer or event
    static var last_received_cid: Int? = nil // campaign id
    static var last_received_type: String? = nil // campaign id
    
    
    static func push(title:String, subtitle:String,attachement: String,identifier: String) {
        
        if #available(iOS 10.0, *) {
            
            let content = UNMutableNotificationContent()
            content.title = title.localized
            content.body = subtitle.localized
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "local"
            
            let url = URL(string: attachement)
            
            Utils.printDebug("attachement: \(attachement)")
            
            guard let imageData = NSData(contentsOf: url!) else {return}
            
            guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "image.jpg", data: imageData, options: nil) else {
                print("error in UNNotificationAttachment.saveImageToDisk()")
                return
            }
            
            content.attachments = [attachment]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if error != nil {
                    // Handle any errors
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
        
    }

    static func push(title:String, subtitle:String,identifier: String) {
        
        if #available(iOS 10.0, *) {
            
            let content = UNMutableNotificationContent()
            content.title = title.localized
            content.body = subtitle.localized
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "local"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
        
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if error != nil {
                    // Handle any errors
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
        
    }
 
    
    
    static func push(msg: String) {
        
        if #available(iOS 10.0, *) {
            
            let content = UNMutableNotificationContent()
            content.title = msg.localized
            content.body = "Hello_message_body".localized
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if error != nil {
                    // Handle any errors
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    
    
}


@available(iOS 10.0, *)
extension UNNotificationAttachment {
    
    @available(iOS 10.0, *)
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}





