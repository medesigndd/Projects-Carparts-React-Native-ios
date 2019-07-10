//
//  UserApi.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Alamofire

protocol ReviewLoaderDelegate:class  {
    //func successUtf8(data: String)
    func success(parser: ReviewParser,response: String)
    func error(error: Error?,response: String)
}

class ReviewLoader: MyApi  {
    
    var TAG: String = "Api.swift"
    
   
    
    var delegate: ReviewLoaderDelegate? = nil
    
    func setDelegate(context: ReviewLoaderDelegate) {
        delegate = context
    }
    
    func load (url: String, parameters: Parameters) {
        
        //self.delegate = delegate
        // let delegate: JobLoaderDelegate? = delegate
        
        
        Alamofire.request(url,method: HTTPMethod.post,parameters: parameters, headers: self.headers).responseJSON { response in
            
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
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    
                    if let jsonDataToVerify = utf8Text.data(using: String.Encoding.utf8)
                    {
                        do {
                            _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)
                            
                            
                            let  parser = self.parser(json: utf8Text)
                            
                            if self.delegate != nil {
                                self.delegate?.success(parser: parser,response: utf8Text)
                            }
                            
                        } catch {
                            
                            Utils.printDebug("Error deserializing JSON: \(error.localizedDescription) ==> \(utf8Text)")
                            
                            if self.delegate != nil {
                                self.delegate?.error(error: nil,response: utf8Text)
                            }
                        }
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
    
    
    var result: ReviewParser? = nil
    
    func parser(json: String) -> ReviewParser {
        
        let mParser = ReviewParser(content: json)
        
        result = mParser
        
        return mParser
    }
    
    
    
    
}




