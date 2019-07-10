//
//  UserApi.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Alamofire

protocol GuestLoaderDelegate:class  {
    //func successUtf8(data: String)
    func success(parser: UserParser,response: String)
    func error(error: Error,response: String)
}

class GuestLoader {
    
    var TAG: String = "Api.swift"
    
    var headers = [
        "Crypto-key": AppConfig.Api.crypto_key,
        "Token": LocalData.getValue(key: "token", defaultValue: "")
    ]
    
    var delegate: GuestLoaderDelegate? = nil
    
    func setDelegate(context: GuestLoaderDelegate) {
        delegate = context
    }
    
    func load (url: String, parameters: Parameters) {
        
        //self.delegate = delegate
        // let delegate: JobLoaderDelegate? = delegate
        
        
        Alamofire.request(url,method: .post,parameters: parameters, headers: self.headers).responseJSON { response in
            
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    if AppConfig.DEBUG {
                        print("Load success")
                    }
                default:
                    if AppConfig.DEBUG {
                        print("error with response status: \(status)")
                    }
                    
                }
            }
            
            
            if self.delegate != nil {
                if let content = response.result.value {
                    
                    let json = content as! [String: Any]
                    let  parser = self.parser(json: json)
                    
                    
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        self.delegate?.success(parser: parser,response: utf8Text)
                    }
                    
                }
                
            }
            
            
            if let error = response.error {
                
                var resp = ""
                
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    resp = utf8Text
                }
                
                if self.delegate != nil {
                    self.delegate?.error(error: error,response: resp)
                }
                
            }
            
            
        }
        
        
        
    }
    
    
    var result: GuestParser? = nil
    
    func parser(json: [String: Any]) -> UserParser {
        
        let mParser = GuestParser(content: json)
        
        result = mParser
        
        return mParser
    }
    
    
    
    
}




