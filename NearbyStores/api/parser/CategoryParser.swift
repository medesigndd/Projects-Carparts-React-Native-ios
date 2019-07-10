//
//  CategoryParser.swift
//  NearbyStores
//
//  Created by Amine on 7/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class CategoryParser: Parser {
    
    func parse() -> [Category] {
        
        var list = [Category]()
        
        if let myResult = self.result {
            
            
            if myResult.count > 0 {
                
                let size = myResult.count-1
                
                for index in 0...size {
                    
                    let object = myResult[ String(index) ]
                    
                    
                    let myObject = Category()
                    
                    myObject.numCat = object["id_category"].intValue
                    
                    myObject.nameCat = object["name"].stringValue
                    myObject.parentCategory = object["parent_id"].intValue
                    
                    myObject.nbr_stores = object["nbr_stores"].intValue
                    
                    
                    let icontent = object["image"]
                    let imageParser = ImagesParser(json: icontent)
                    let image = imageParser.parseSingle()
                    myObject.images = image
                
                    
                    list.append(myObject)
                    
                }
                
                
            }
            
            
            return list
        }
        
        return []
    }
}
