//
//  AppConfig.swift
//
//  Created by DT Team on 5/14/18.
//  Eamil: droideve.tech@gmail.com
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons

class AppConfig {
    
    //AppConfiguration
    static let DEBUG: Bool = false
  
    //Maps Config
    static let GOOGLE_MAPS_KEY = "*** GOOGLE MAPS KEY HERE ***" //get it from google console
    
    
    //API SERVER CONFIG
    struct Api {
        static let ios_api              = "*** IOS API KEY ***"    // get it from dashboard
        static let base_url             = "http://domain.com/index.php"
        static let base_url_api         = "http://domain.com/index.php/api"
        static let terms_of_use_url     = "http://domain.com/term_of_uses.html"
        static let privacy_policy_url   = "http://domain.com/privacy_policy.html"
    }
    
    //ADMOB CONFIG
    struct Ads {
        
        static let AD_APP_ID            = "*** ADMOB APP ID ***"
        static let AD_BANNER_ID         = "*** ADMOB BANNER ID ***"
        static let AD_INTERSTITIEL_ID   = "*** ADMOB INTERSTITIEL ID ***"

        
        //Enable/Disable
        static let ADS_ENABLED                  = true //enable/disable all ads
        static let ADS_BANNER_ENABLED           = true
        static let ADS_INTERSTITIEL_ENABLED     = false
        
        static let BANNER_IN_STORE_DETAIL_ENABLED   = true
        static let BANNER_IN_OFFER_DETAIL_ENABLED   = true
        static let BANNER_IN_EVENT_DETAIL_ENABLED   = true

    }
    
    //App Name
    static let APP_NAME = Bundle.main.infoDictionary?["CFBundleName"] as! String
    
    
    //Enable/Disable Chat in your App
    static let CHAT_ENABLED = true
    
    

    
    //Config Colors & Fonts
    struct Design {
        
        //Some proposed colors from google
        //https://material.io/design/color/the-color-system.html
        enum Colors {
            static let primaryColor = "#E53935"
            static let accentColor = "#F44336"
            static let darkColor = "#C62828"
            static let darkIconColor = "#B71C1C"
            static let featuredTagColor = "#1565C0"
            static let promoTagColor = "#E53935"
            static let upComingColor = "#E65100"
        }
      
        //See how to set custom font
        //https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app
        enum Fonts {
            static let regular = "OpenSans"
            static let italic = "OpenSans-Italic"
            static let bold = "OpenSans-Bold"
        }
        
        
    }
    
    
    //Main Config
    struct Tabs {
        
        enum Tags {
            static let TAG_STORES = "stores"
            static let TAG_OFFERS = "offers"
            static let TAG_EVENTS = "events"
            static let TAG_INBOX = "inbox"
        }
        
        static let Pages: [String] = [
            Tags.TAG_STORES, // stores
            Tags.TAG_OFFERS, // offers
            Tags.TAG_EVENTS, // Events
            Tags.TAG_INBOX,  // Inbox
        ]
        
        static let TabIcons: [String: FontType] = [
            Tags.TAG_STORES: .linearIcons(.store),
            Tags.TAG_OFFERS: .linearIcons(.tag),
            Tags.TAG_EVENTS: .linearIcons(.calendarFull),
            Tags.TAG_INBOX:  .linearIcons(.inbox),
        ]
    
    }
    
    static let distanceMaxValue = 100 //By KM 
    static let distanceUnit = Distance.Types.Kilometers
    
 
    
   
    //About Company Or Project
    struct About {
        
        static let ABOUT_US = "NEARBYSTORES is an innovative local business search app with an intelligent search functionality that can help you find different businesses in an area easily. It has a powerful store locator admin that allows you to manage stores, categories, notification, business owner, events and offers"
        
        static let EMAIL = "contact@droidev-tech.com"
        static let TEL = "+1 000 000 00"
    }
    
    //Enable/Disable Menu Items
    struct Menu {
        /*
         to manage menu list, should remove each id from the list
         */
        static let list = [
            MenuIDList.CATEGORIES : true,
            MenuIDList.GEO_STORES : true,
            MenuIDList.CHAT_LOGIN : true,
            MenuIDList.PEOPLE_AROUND_ME : true,
            MenuIDList.FAVOURITES : true,
            MenuIDList.MY_EVENTS : true,
            MenuIDList.EDIT_PROFILE : true,
            MenuIDList.LOGOUT : true,
            MenuIDList.MANAGE_STORES : false,
            MenuIDList.SETTING : true,
            MenuIDList.ABOUT : true,
            MenuIDList.CLOSE : true,
            ]
    }
    
    let app_version = "1.4.2" // please don't touch this
    
    
    
    
}
