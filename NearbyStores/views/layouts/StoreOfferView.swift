//
//  StoreOfferCell.swift
//  NearbyStores
//
//  Created by Amine on 7/4/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Kingfisher

class StoreOfferView: UIView {
    
    @IBOutlet weak var descriptionLabelCover: GradientBGView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var promoTag: EdgeLabel!
    
    @IBOutlet weak var itemBtn: UIButton!
    
    @IBAction func onPress(_ sender: Any) {
        
    }
    
    
    @IBOutlet weak var container: UIView!
    func settings() {
        
        promoTag.leftTextInset = 15
        promoTag.rightTextInset = 15
        promoTag.topTextInset = 5
        promoTag.bottomTextInset = 5
        promoTag.backgroundColor = Colors.primaryColor
        promoTag.textColor = UIColor.white
        
        
        image.layer.cornerRadius = 5/UIScreen.main.nativeScale
        image.layer.masksToBounds = true
        
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        
        
    }
    
    func setup(object: Offer) {
        
        self.title.text = object.name
        self.labelDescription.text = object.store_name
        
        
        if let image = object.images {
            
            let url = URL(string: image.url500_500)
            
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
        }else{
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
        
        
        if let content = object.content {
            
            if content.percent > 0 || content.percent<0 {
                
                promoTag.text = "\(content.percent)%"
                
            }else if content.price != 0 {
                if let currency = content.currency {
                    if let pprice = currency.parseCurrencyFormat(price: content.price){
                        promoTag.text = pprice
                    }
                }
            }
            
        }
        
        
    }
    
    
    
    
}
