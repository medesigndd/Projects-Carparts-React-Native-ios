//
//  UserApi.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Alamofire


class SimpleLoader: MyApi  {
    
    var TAG: String = "Api.swift"
    
    func run (url: String, parameters: Parameters,compilation: @escaping (Parser?) -> () ) {
        
        compilation(nil)
        //self.delegate = delegate
        // let delegate: JobLoaderDelegate? = delegate

        Alamofire.request(url,method: HTTPMethod.post ,parameters: parameters, headers: self.headers).responseJSON { response in
            
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
            
           
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
               
                
                if let jsonDataToVerify = utf8Text.data(using: String.Encoding.utf8)
                {
                    do {
                        _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)
                        
                        Utils.printDebug("JSON: \(utf8Text)")
                        
                        let  parser = Parser(content: utf8Text)
                        compilation(parser)
                      
                    } catch {
                        Utils.printDebug("Error deserializing JSON: \(error.localizedDescription) = Data:  \(utf8Text)")
                    }
                }
                
                
            }
            
            
            if response.error != nil {
                
                var resp = ""

                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    resp = utf8Text
                }

                
            }
            
            
        }

    }
    
   
    
  
    
    
    
}




