//
//  AppSetting.swift
//  NearbyStores
//
//  Created by Amine on 5/21/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class AppSetting {
    

}

extension AppSetting {
    
    static func isInitialized() -> Bool {
        
        let token = LocalData.getValue(key: "token", defaultValue: "")
        if token != "" {
            return true
        }
        
        return false
    }
    
}
