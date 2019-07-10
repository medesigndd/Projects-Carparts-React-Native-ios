//
//  Api.swift
//  NearbyStores
//
//  Created by Amine on 5/23/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class Api {

    let headers = [
        "Crypto-key": AppConfig.Api.crypto_key,
        "Token": LocalData.getValue(key: "token", defaultValue: "")
    ]
}
