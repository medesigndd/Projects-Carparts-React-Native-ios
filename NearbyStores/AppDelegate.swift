//
//  AppDelegate.swift
//  NearbyStores
//
//  Created by Amine on 5/19/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import SwiftEventBus
import GoogleMaps
import GoogleMobileAds


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //init app settings
        let first_time = LocalData.getValue(key: "first_time", defaultValue: 1)
        if first_time == 0{
            LocalData.setValue(key: Settings.Keys.OFFERS_NOTIFICATION, value: true)
            LocalData.setValue(key: Settings.Keys.STORES_NOTIFICATION, value: true)
            LocalData.setValue(key: Settings.Keys.EVENTS_NOTIFICATION, value: true)
            LocalData.setValue(key: Settings.Keys.CEVENTS_NOTIFICATION, value: true)
            LocalData.setValue(key: Settings.Keys.MESSENGER_NOTIFICATION, value: true)
            LocalData.setValue(key: "first_time", value: 1)
        }
        
       
        UIApplication.shared.statusBarStyle = .lightContent
        
        GMSServices.provideAPIKey(AppConfig.GOOGLE_MAPS_KEY)
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
    
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })

        } else {

            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)

        }
        
       application.registerForRemoteNotifications()
        
        self.setup(application: application)
        
    
        GADMobileAds.configure(withApplicationID: AppConfig.Ads.AD_APP_ID)
        
        return true
    }
    
    
    
   
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

     
        
        // Print full message.
        print(userInfo)
        
    }
    

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let text = userInfo["text"] {
            
            let icdParser = InComingDataParser(content: text as? String)
            icdParser.proccess()
            
        }
        
        Utils.printDebug("\(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    

    
   
    
    
   
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        
        
        // With swizzling disabled you must set the APNs token here.
         Messaging.messaging().apnsToken = deviceToken
    }

    
    func setup(application: UIApplication)  {
        
       
        UINavigationBar.appearance().barTintColor = Colors.primaryColor
      
        
        let statusBarBackgroundView = UIView()
        statusBarBackgroundView.backgroundColor = Colors.darkColor
        
        window?.addSubview(statusBarBackgroundView)
        window?.addConstraintsWithFormat(format: "H:|[v0]|", views: statusBarBackgroundView)
        window?.addConstraintsWithFormat(format: "V:|[v0(20)]", views: statusBarBackgroundView)
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    
    

    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage)")
        
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        application.registerForRemoteNotifications()
    }
    
    
    
    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let aps = userInfo["aps"] {
            print("Data: \(aps)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert,.sound])
    }
    
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        let userInfo = response.notification.request.content.userInfo
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        let status: UIApplicationState = UIApplication.shared.applicationState // or use  let state =  UIApplication.sharedApplication().applicationState
    
        if response.notification.request.identifier == InComingDataParser.tag_new_message {
            
        
            //update badge
            SwiftEventBus.post("on_badge_refresh", sender: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                if MainViewController.isAppear {
                    for index in 0...AppConfig.Tabs.Pages.count{
                        if AppConfig.Tabs.Pages[index] == AppConfig.Tabs.Tags.TAG_INBOX{
                            SwiftEventBus.post("on_main_redirect", sender: index)
                            break
                        }
                    }
                }
                
            }
  
            
        }else if response.notification.request.identifier ==  CampaignParser.OFFER {
            
            var parameters = [
                "cid":  ""
            ]
            
            if let cid = NotificationManager.last_received_cid{
                parameters["cid"] = "\(cid)"
            }
            
            Utils.printDebug("API_MARK_VIEW: \(parameters)")
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_MARK_VIEW, parameters: parameters, compilation: { (parser) in
                if parser?.success == 1 {
                    
                }
            })
            
            if status == .active{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    SwiftEventBus.post("open_view_"+CampaignParser.OFFER, sender:["oid":oid,"cid":cid])
                }

            }else if status == .background{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    SwiftEventBus.post("open_view_"+CampaignParser.OFFER, sender:["oid":oid,"cid":cid])
                }
                
            }else{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    SwiftEventBus.post("open_view_"+CampaignParser.OFFER, sender:["oid":oid,"cid":cid])
                }
                
            }
            
            
        }else if response.notification.request.identifier == CampaignParser.STORE {
            
            var parameters = [
                "cid":  ""
            ]
            
            if let cid = NotificationManager.last_received_cid{
                parameters["cid"] = "\(cid)"
            }
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_MARK_VIEW, parameters: parameters, compilation: { (parser) in
                if parser?.success == 1 {
                    
                }
            })
            
            if status == .active{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    SwiftEventBus.post("open_view_"+CampaignParser.STORE, sender:["oid":oid,"cid":cid])
                }
                
            }else{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    SwiftEventBus.post("open_view_"+CampaignParser.STORE, sender:["oid":oid,"cid":cid])
                }
                
            }
            
        }else if response.notification.request.identifier ==  CampaignParser.EVENT {
            
        
            var parameters = [
                "cid":  ""
            ]
            
            if let cid = NotificationManager.last_received_cid{
                parameters["cid"] = "\(cid)"
            }
            
            let api = SimpleLoader()
            api.run(url: Constances.Api.API_MARK_VIEW, parameters: parameters, compilation: { (parser) in
                if parser?.success == 1 {
                    
                }
            })
            
            if status == .active{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    SwiftEventBus.post("open_view_"+CampaignParser.EVENT, sender:["oid":oid,"cid":cid])
                }
                
            }else if status == .background{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    SwiftEventBus.post("open_view_"+CampaignParser.EVENT, sender:["oid":oid,"cid":cid])
                }
            }else{
                
                let cid = NotificationManager.last_received_cid
                let oid = NotificationManager.last_received_oid
                
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    SwiftEventBus.post("open_view_"+CampaignParser.EVENT, sender:["oid":oid,"cid":cid])
                }
            }
            
            
            
        }else if response.notification.request.identifier ==  "upcomingevents" {
         
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                SwiftEventBus.post("open_view_list_event", sender:ListEventCell.Request.upcoming)
            }
            
       }
        
        
        NotificationManager.last_received_cid = nil
        NotificationManager.last_received_oid = nil
        NotificationManager.last_received_type = nil
        
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }


}




extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

