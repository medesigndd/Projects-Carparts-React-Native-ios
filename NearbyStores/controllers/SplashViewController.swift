//
//  SplashViewController.swift
//  NearbyStores
//
//  Created by Amine on 5/19/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import CoreLocation
import AssistantKit

class SplashViewController: UIViewController, CLLocationManagerDelegate {
    
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D? = nil
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        self.currentLocation = locValue
        
        Utils.printDebug("\(locations)")
       
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.requestLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                
                self.requestLocation()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if Guest.isStored() == false {
                        self.guest_refresh(startMain: true)
                    }else{
                         self.guest_refresh(startMain: false)
                    }
                    
                }
                
            }
        } else {
            
            if Constances.Global.GPS_REQUIRE_ENABLE{
                self.enableGPS()
            }else {
                self.requestLocation()
            }
        }
        
        
        
    }
    
    func requestLocation() {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    @IBOutlet weak var app_icon_height: NSLayoutConstraint!
    
    @IBOutlet weak var app_icon_width: NSLayoutConstraint!
    
   
    
    override func viewDidAppear(_ animated: Bool) {
    
        if stopExecute{
            return
        }
        
        if !Connectivity.isConnected() {
            self.showAlertInitError(title: "Opps - Connection error!".localized,msg: "\nCould't connect with server side!\n Please check your internet connection".localized,msgBnt: "Turn on".localized, clicked: {
                if let url = URL(string:"App-Prefs:root=Settings&path=General") {
                    UIApplication.shared.openURL(url)
                }
                
                self.showAlertInitError(title: "Opps - Connection error!".localized,msg: "\nCould't connect with server side!\n Please check your internet connection".localized,msgBnt: "Refresh".localized, clicked: {
                    if Connectivity.isConnected() {
                        self.startApp()
                    }else{
                        self.viewDidAppear(true)
                    }
                })
                
            })
            //show alert
        }else{
            
           
            startApp()
        
            
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        app_icon_splash.isHidden = true
        
        
        if let language = Locale.current.languageCode{
            LocalData.setValue(key: "language", value: language)
        }else{
            LocalData.setValue(key: "language", value: "en")
        }
        
    }
    
    
    func startApp()  {
        
        
        //Setup location
        locationManager.delegate = self
    
        //remove caches
        self.initCache()
        
        //refresh FCM for push notification
        self.refreshFCM()
        
        //check user if is connected
        self.checkUserState()
       
        //check device version
        Utils.printDebug("Phone Inches => \(Device.screen)")
        Utils.printDebug("Phone Version => \(Device.version)")
        Utils.printDebug("Phone type => \(Device.type)")
        
        
        if Device.isPad{
            app_icon_width.constant = app_icon_width.constant+100
            app_icon_height.constant = app_icon_height.constant+100
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let animation = UIAnimation(view: self.app_icon_splash)
            animation.zoomIn()
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            if AppSetting.isInitialized() == false {
                //load token from server
                self.app_init()
            }else {
                //start next interface
                self.refreshFCM()
                self.refreshLocationAndStartMain()
            }
        }
        
    }

    
    func refreshLocationAndStartMain() {
        
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                
            case .notDetermined, .restricted, .denied:
                self.requestLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                
                if Guest.isStored() {
                    self.startMainVC()
                }else{
                    self.guest_refresh(startMain: true)
                }
                
            }
            
        } else {
            
            if Constances.Global.GPS_REQUIRE_ENABLE{
                self.enableGPS()
            }else {
                 self.requestLocation()
            }
            
        }
        
    }

    
    
    
    @IBOutlet weak var app_icon_splash: UIImageView!
    
    func startConnectionVC() {
        
        //stop updating location
        locationManager.stopUpdatingLocation()
        
        
        let animation = UIAnimation(view: self.app_icon_splash)
        animation.zoomOut()
        
      
        let sb = UIStoryboard(name: "Connection", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    func startMainVC() {
        
         //stop updating location
        locationManager.stopUpdatingLocation()
        
        let animation = UIAnimation(view: self.app_icon_splash)
        animation.zoomOut()
        
        let layout = UICollectionViewFlowLayout()
        let main = UINavigationController(rootViewController: MainViewController(collectionViewLayout: layout))
        

        self.present(main, animated: true) {
            self.stopExecute = true
        }
       
    }
    
    private var stopExecute = false;
    
    func app_init() {
        
        
        Utils.printDebug("Init started!")
        
        let api = MyApi()

        let headers = api.headers
        
    
        let params = [
            "Api-key-ios": AppConfig.Api.ios_api
        ]
        
        Utils.printDebug("Headers: \(headers)")
        
        Alamofire.request(Constances.Api.API_APP_INIT,method: .post,parameters: params, headers: headers).responseJSON { response in
            
            if let error = response.error{
                Utils.printDebug("\(error)")
            }
            
          
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                
                Utils.printDebug("\(utf8Text)")
                 
            }
            
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    Utils.printDebug("Load success")
                case 500:
                    self.showError(status: 500)
                default:
                    
                    Utils.printDebug("error with response status: \(status)")
                }
            }
            
            Utils.printDebug("Init ended with data! ==> \(response.data!)")
            
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                
                
                if let jsonDataToVerify = utf8Text.data(using: String.Encoding.utf8)
                {
                    do {
                        _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)
                        
                        Utils.printDebug("Init ended with json! ==> \(utf8Text)")
                        
                        let parser = Parser(content: utf8Text)
                        
                        if parser.success == 1 {
                            
                            let token = parser.json!["token"].stringValue
                            LocalData.setValue(key: "token", value: token)
                        
                            
                            self.refreshFCM()
                            self.requestLocation()
                            self.refreshLocationAndStartMain()
                            
                        }else{
                            
                            self.locationManager.stopUpdatingLocation()
                            self.showAlertInitError(title: "Opps - Initialization error!".localized,msg: "\nCould't connect with server side!\n Please check API key".localized,msgBnt: "EXIT".localized, clicked: {
                                exit(0)
                            })
                            //show alert
                            
                            
                        }
                        
                        
                        
                    } catch {
                        
                        Utils.printDebug("Error deserializing JSON: \(error.localizedDescription)")
                        
                        self.showAlertInitError(title: "Opps - Initialization error!".localized,msg: "\nCould't connect with server side!\n Please check your network".localized,msgBnt: "EXIT".localized, clicked: {
                            exit(0)
                        })
                        
                        self.locationManager.stopUpdatingLocation()
                        
                    }
                    
                }else{
                    
                    self.refreshFCM()
                    self.requestLocation()
                    
                }
                
            }else{
                
              
            }
            
        }
        
        
    }
    
    
    func showError(status: Int)  {
        self.showAlertInitError(title: "Opps - Initialization error!",msg: "\nCould't connect with server side!\n error with response status: \(status)",msgBnt: "EXIT", clicked: {
            exit(0)
        })
    }
    
    
    func refreshFCM () {
        
         Utils.printDebug("Get FCM token")
        if let refreshedToken = InstanceID.instanceID().token() {
            Utils.printDebug("InstanceID token: \(refreshedToken)")
        }
    }
    
    
   
    func guest_refresh(startMain: Bool) {
        
        let api = MyApi()
        let headers = api.headers
        
        // Get unique device ID
        var token = ""
        if let refreshedToken = InstanceID.instanceID().token() {
            token = refreshedToken
        }else {
            token = ""
        }
        
        //Get current Location
        var lat = 0.0
        var lng = 0.0
        
        if let location = currentLocation {
            lat = location.latitude
            lng = location.longitude
        }
        
        
        let parameters = [
            "fcm_id": token,
            "sender_id": Token.getDeviceId(),
            "mac_adr": Token.getDeviceId(),
            "platform": "ios",
            "lat": String(lat),
            "lng":String(lng)
        ]
        
        
        Utils.printDebug("headers: \(headers)")
        Utils.printDebug("parameters: \(parameters)")
        
        
        Alamofire.request(Constances.Api.API_USER_REGISTER_TOKEN,method: .post,parameters: parameters, headers: headers).responseJSON { response in
  
            
            if let error = response.error{
                Utils.printDebug("\(error)")
            }
           
            
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    Utils.printDebug("Load success")
                case 500:
                    self.showError(status: 500)
                default:
                    Utils.printDebug("response with status: \(status)")
                    self.locationManager.stopUpdatingLocation()
                }
            }
            
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                
                Utils.printDebug("\(utf8Text)")
                
                let parser = GuestParser(content: utf8Text)
                
                if parser.success == 1 {
                    
                    let guests = parser.parse()
                    
                    if guests.count > 0 {
                        
                        Guest.saveGuest(guest: guests[0])
                        
                        if let g = Guest.getInstance() {
                            Utils.printDebug("Guest Instance ==> \(startMain) \(g)")
                        }
                        
                    }
                    
                    if startMain {
                        self.startMainVC()
                    }
                    
                    
                }else if parser.success == -1{
                    
                    if let errors = parser.errors{
                        
                        self.showAlertInitErrors(title: "Api error!".localized, content: errors, msgBnt: "EXIT")
                     }
                    
                }
                
            }else {
                
                if startMain {
                    self.startMainVC()
                }
                
                
            }
            
            
            
        }
        

    }
    
    
    
    
  
   
    
    
    func enableGPS()  {
        
        
        let alert = UIAlertController(title: "Enable GPS", message: "GPS access is restricted. In order to use tracking, please enable GPS in the Settigs app under Privacy, Location Services.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
           
            
            if !CLLocationManager.locationServicesEnabled() {
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.openURL(url)
                }
            } else {
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    // If general location settings are enabled then open location settings for the app
                    UIApplication.shared.openURL(url)
                }
            }
            
        }))
        
        self.present(alert, animated: true)
    }
    
    
    
    func initCache()  {
        
        //remove all stored messages
        Message.removeAll()
        MessengerCache.removeAll()
        
    }

    
    
    func checkUserState() {
        
        guard Session.isLogged() else { return }
        guard let session = Session.getInstance(), let user = session.user else { return }
        
        let api = UserLoader()
        
        let params = [
            "email":user.email,
            "userid":String(user.id),
            "username":user.username,
            "senderid":user.senderid,
        ]
        
        
        
        api.run(url: Constances.Api.API_USER_CHECK_CONNECTION, parameters: params) { (userParser) in
            
            guard let parser = userParser else{ return }
            
            if parser.success == 1 {
                let users = parser.parse()
                if users.count == 0{
                    let _ = Session.logout()
                }else{
                    users[0].save()
                }
            }
   
        }
        
    }
    
    
 
    
    
    

}
