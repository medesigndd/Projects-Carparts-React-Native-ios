//
//  Token.swift
//  NearbyStores
//
//  Created by Amine on 5/27/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

struct Token {
    
    
    
    static func getDeviceId() -> String{
        
        if let identifier = UIDevice.current.identifierForVendor{
            return identifier.uuidString
        }
        
        
        return ""
    }
    
}
