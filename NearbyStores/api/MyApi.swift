//
//  MyApi.swift
//  NearbyStores
//
//  Created by Amine on 7/25/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Alamofire

class MyApi {
    
    var headers = [
        "Api-key-ios": AppConfig.Api.ios_api,
        "Debug": "\(AppConfig.DEBUG)",
        "Token": LocalData.getValue(key: "token", defaultValue: ""),
        "Language": LocalData.getValue(key: "language", defaultValue: "")
    ]

}
