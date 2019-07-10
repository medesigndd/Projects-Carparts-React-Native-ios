//
//  StoreReviewView.swift
//  NearbyStores
//
//  Created by Amine on 7/6/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Cosmos

class StoreReviewView: UIView {

   
    @IBOutlet weak var descriptionLabelCover: GradientBGView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var username: UILabel!
   
    @IBOutlet weak var container: UIView!
    
    
    @IBOutlet weak var ratingContainer: UIView!
    
    @IBOutlet weak var itemBtn: UIButton!
    
    func settings() {
        
        image.layer.borderWidth = 2
        image.layer.masksToBounds = false
        image.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
        
        self.backgroundColor = UIColor.yellow
        
        self.ratingContainer.addSubview(ratingView)
       
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(
            item: ratingView,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal,
            toItem: ratingContainer,
            attribute: NSLayoutAttribute.right,
            multiplier: 1, constant: 0
        ))
        
        constraints.append(NSLayoutConstraint(
            item: ratingView,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: ratingContainer,
            attribute: NSLayoutAttribute.top,
            multiplier: 1, constant: 0
        ))
        
        constraints.append(NSLayoutConstraint(
            item: ratingView,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: ratingContainer,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1, constant: 0
        ))
        
        self.ratingContainer.addConstraints(constraints)
    }
    
    func setup(object: Review) {
        
        self.username.text = object.pseudo.capitalizingFirstLetter()
        self.commentLabel.text = object.review
        
        
        if object.image != "" {
            
            let url = URL(string: object.image)
            
            self.image.kf.indicatorType = .activity
            if let img = UIImage(named: "profile_placeholder") {
                self.image.kf.setImage(with: url, placeholder: img, options: [.transition(.fade(0.2))], progressBlock: nil)
            }
            
        }else{
            if let img = UIImage(named: "profile_placeholder") {
                self.image.image = img
            }
        }
        
        self.ratingView.rating = object.rate
        
    }
    
    
    
    let ratingView: CosmosView = {
        
        
        
        let cosmosView = CosmosView()
        
        cosmosView.rating = 0
        
        // Change the text
        cosmosView.text = ""
        cosmosView.settings.textColor = Colors.black
        cosmosView.settings.updateOnTouch = false
        
        if let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 12) {
            cosmosView.settings.textFont = font
        }
        
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
        cosmosView.didFinishTouchingCosmos = { rating in }
        
        // A closure that is called when user changes the rating by touching the view.
        // This can be used to update UI as the rating is being changed by moving a finger.
        cosmosView.didTouchCosmos = { rating in }
        
        
        return cosmosView
    }()
    

}
