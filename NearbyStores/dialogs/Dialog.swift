//
//  Dialog.swift
//  NearbyStores
//
//  Created by Amine on 5/21/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlertInitError(title: String,msg: String,msgBnt: String,clicked: @escaping ()->()) {
        
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: msgBnt, style: .default, handler: { action in
            clicked()
        }))
    
       
        self.present(alert, animated: true)
    }
    
    
    func showAlertInitErrors(title: String,content: [String: String],msgBnt: String) {
        
        var message = "\n"
        
        for (_,msg) in content {
            message = "\(message) \(msg) \n"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: msgBnt, style: .default, handler: { action in
            exit(0)
        }))
        
        

        self.present(alert, animated: true)
    }
    
    
    func showAlertError(title: String,content: [String: String],msgBnt: String) {
        
        var message = "\n"
        
        for (_,msg) in content {
            message = "\(message) \(msg) \n"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: msgBnt, style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
    
        
        
        self.present(alert, animated: true)
    }
}
