//
//  Review.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class Review: Object {

  
    @objc dynamic var id_rate: Int = 0
    @objc dynamic var store_id: Int = 0
    @objc dynamic var rate: Double = 0
    @objc dynamic var review: String = ""
    @objc dynamic var pseudo: String = ""
    @objc dynamic var image: String = ""
    @objc dynamic var guest_id: Int = 0

    override static func primaryKey() -> String? {
        return "id_rate"
    }
    
}
