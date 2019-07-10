//
//  OfferCell.swift
//  NearbyStores
//
//  Created by Amine on 6/7/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons

class OfferCell: UICollectionViewCell {

    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var featured: EdgeLabel!
    
    @IBOutlet weak var offer: EdgeLabel!
    
    @IBOutlet weak var store_name: UILabel!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var distance: EdgeLabel!
    
    func setupSettings()  {
        
        
        //offers tag
        offer.leftTextInset = 15
        offer.rightTextInset = 15
        offer.topTextInset = 10
        offer.bottomTextInset = 10
        offer.backgroundColor = Colors.darkColor
        
        
        featured.leftTextInset = 10
        featured.rightTextInset = 10
        featured.bottomTextInset = 5
        featured.topTextInset = 5
        featured.backgroundColor = Colors.featuredTagColor
        
        
        
        distance.leftTextInset = 15
        distance.rightTextInset = 15
        distance.topTextInset = 10
        distance.bottomTextInset = 10
        distance.backgroundColor = Colors.primaryColor
        
        
        image.contentMode = .scaleAspectFill
        
        
    }
    
    func setup(object: Offer)  {
        
        
        self.title.text = object.name
        self.store_name.text = object.store_name
        
        let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: UIColor.white)
        
        if Utils.isRTL(){
            self.store_name.setRightIcon(image: icon)
        }else{
           self.store_name.setLeftIcon(image: icon)
        }
        
        
        if let image = object.images {
            
            let url = URL(string: image.url500_500)
            
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
        }else{
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
        
        
        if object.featured == 1 {
            self.featured.isHidden = false
        }else {
            self.featured.isHidden = true
        }
        
        let distance = object.distance.calculeDistance()
        self.distance.text = distance.getCurrent(type: Distance.Types.Kilometers)
        
        if let content = object.content {
            
            if content.percent > 0 || content.percent<0 {
                
                offer.text = "\(content.percent)%"
                
            }else if content.price != 0 {
                if let currency = content.currency {
                    if let pprice = currency.parseCurrencyFormat(price: content.price){
                        offer.text = pprice
                    }
                }
            }
            
        }
        
        
    }
    
    
   
}










