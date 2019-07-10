//
//  UserParser.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

//
//  JobParser.swift
//  AppTest
//
//  Created by Amine on 5/15/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class ImagesParser: Parser {
    
    
    func parse() -> [Images] {
        
        var list = [Images]()
        
       
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    
                    
                  
                    
                    let myObject = Images()
                    
                    myObject.id = object["name"].stringValue
                    
                    myObject.url100_100 = object["100_100"]["url"].stringValue
                    myObject.url200_200 = object["200_200"]["url"].stringValue
                    myObject.url500_500 = object["560_560"]["url"].stringValue
                    
                    
                    list.append(myObject)
                        
  
                }
                
                
            }
            
            
            
            
            
            return list
        }
        
        return []
    }
    
    
    func parseSingle() -> Images? {
        
        if let object = self.result {
            
        
            let myObject = Images()
            
        
           
            myObject.id = object["name"].stringValue
            
            myObject.url100_100 = object["100_100"]["url"].stringValue
            myObject.url200_200 = object["200_200"]["url"].stringValue
            myObject.url500_500 = object["560_560"]["url"].stringValue
            
            
            return myObject
            
            
    
        }
        
        return nil
    }
    
}



