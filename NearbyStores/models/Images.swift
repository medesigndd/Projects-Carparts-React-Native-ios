//
//  Images.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Images: Object {
    
    
    @objc dynamic var id: String = ""
    @objc dynamic var url200_200: String = ""
    @objc dynamic var url500_500: String = ""
    @objc dynamic var url100_100: String = ""
    @objc dynamic var height: Int = 0
    @objc dynamic var width: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
