//
//  CustomViewMarker.swift
//  NearbyStores
//
//  Created by Amine on 7/1/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import GoogleMaps

class CustomViewStoreMarker: UIView {
    

    var imageUrl = ""
    var isHasPromo = false
    
    var object: Store? = nil

    
    func setup(marker: GMSMarker) {
        
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        
        if let object = self.object {
            
            
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            
            imageView.contentMode = .scaleAspectFill
            
            imageView.layer.cornerRadius = 5
            imageView.layer.borderColor = Colors.primaryColor.cgColor
            imageView.layer.borderWidth = 2
            imageView.clipsToBounds = true
            imageView.backgroundColor = UIColor.gray
         
             self.addSubview(imageView)
            
            if object.lastOffer != ""{
                let promo = UILabel()
                promo.text = "Promo".localized
                promo.backgroundColor = Colors.promoTagColor
                promo.textColor = Colors.black
                self.addSubview(promo)
            }
            
            
            if object.listImages.count > 0 {
                
                if let first = object.listImages.first {
                    
                    let url = URL(string: first.url200_200)
                    
                    if let placeHolder = UIImage(named: "default_store_image") {
                        
                        
                        imageView.kf.indicatorType = .activity
                        imageView.kf.setImage(with: url, placeholder: placeHolder, options: [.transition(.fade(0.2))])
                        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
                        
                        self.layer.render(in: UIGraphicsGetCurrentContext()!)
                        let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                        UIGraphicsEndImageContext()
                        marker.icon = imageConverted
                        
                        
                        imageView.kf.setImage(with: url, completionHandler: {
                            (image, error, cacheType, imageUrl) in
                            
                            UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
                            
                            self.layer.render(in: UIGraphicsGetCurrentContext()!)
                            let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                            UIGraphicsEndImageContext()
                            
                            marker.icon = imageConverted
                            
                        })
                    }
                    
                }else{
                    if let img = UIImage(named: "default_store_image") {
                        imageView.image = img
                    }
                }
            }else{
                
                if let img = UIImage(named: "default_store_image") {
                    imageView.image = img
                }
            }
        
        }
        
        
       
        
    }
    
   
    
}
