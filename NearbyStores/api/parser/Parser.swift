//
//  Parser.swift
//  AppTest
//
//  Created by Amine on 5/15/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftyJSON

class Parser {
    
    struct TAGS {
        static let SUCCESS = "success"
        static let RESULT = "result"
        static let ERRORS = "errors"
        static let COUNT = "count"
        static let PAGE = "page"
        static let ARGS = "args"
    }
    
    var success = -1
    var errors: [String: String]? = nil
    var result: JSON? = nil
    var count: Int = -1
    var page: Int = -1
    
    var json: JSON? = nil
    
    
    init(content: String) {
        
        self.success = 0
        self.errors = nil
        self.result = nil
        self.count = 0
        self.page = 0
        
        
        
       if let dataFromString = content.data(using: .utf8, allowLossyConversion: false) {
        
            do {
                
                
                
                self.json = try JSON(data: dataFromString)
            
                
                self.success = self.json![TAGS.SUCCESS].intValue
                self.errors = self.json![TAGS.ERRORS].dictionaryObject as? [String : String]
                let args: JSON = self.json![TAGS.ARGS]
                self.count = args[TAGS.COUNT].intValue
                self.page = self.json![TAGS.PAGE].intValue
                self.result = self.json?[TAGS.RESULT]
                
                if self.count == 0 {
                   self.count = self.json![TAGS.COUNT].intValue
                }
                
            } catch {
                Utils.printDebug("json content not valid! => \(content)")
                print(error.localizedDescription)
            }
        
        }
        
        
    }
    
    

    
    
    
    
    
    
    init(json: JSON) {
        
        self.json = json
        self.result = json
        
    }
  
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
}
