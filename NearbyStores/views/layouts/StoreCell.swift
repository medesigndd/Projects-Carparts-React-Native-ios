//
//  StoreCell.swift
//  NearbyStores
//
//  Created by Amine on 5/31/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Cosmos
import Kingfisher

class StoreCell: UICollectionViewCell {
    
    
    //Outlets

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var infosContainer: UIView!
    @IBOutlet weak var sale: EdgeLabel!
    
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var offers: EdgeLabel!
   
    @IBOutlet weak var ratingContainer: UIView!
    
    @IBOutlet weak var lastOffer: EdgeLabel!
    
    @IBOutlet weak var featured: EdgeLabel!
    
    @IBOutlet weak var addressCover: UIView!
    
    @IBOutlet weak var highlightedCover: UIView!
    
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted{
                highlightedCover.backgroundColor = Colors.white.withAlphaComponent(0.2)
            }else{
                highlightedCover.backgroundColor = UIColor.clear
            }
        }
    }
    
    func setupSettings()  {
        
       
        //distance tag
        distance.leftTextInset = 10
        distance.rightTextInset = 10
        distance.bottomTextInset = 5
        distance.topTextInset = 5
        distance.backgroundColor = Colors.darkColor
       
        
        //offers tag
        offers.leftTextInset = 10
        offers.rightTextInset = 10
        offers.topTextInset = 5
        offers.bottomTextInset = 5
        offers.backgroundColor = Colors.primaryColor
        
        
        //offers tag
        sale.leftTextInset = 15
        sale.rightTextInset = 15
        sale.topTextInset = 10
        sale.bottomTextInset = 10
        sale.backgroundColor = Colors.primaryColor
        
        
        featured.leftTextInset = 10
        featured.rightTextInset = 10
        featured.bottomTextInset = 5
        featured.topTextInset = 5
        featured.backgroundColor = Colors.featuredTagColor
       
    
        image.contentMode = .scaleAspectFill
        
        ratingContainer.addSubview(ratingView)
      
        
        
        //if it is RTL
        if Utils.isRTL(){
            
            ratingView.translatesAutoresizingMaskIntoConstraints = false
            ratingContainer.addConstraints([
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .top,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: ratingContainer,
                    attribute: .top,
                    multiplier: 1, constant: 0),
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .bottom,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: ratingContainer,
                    attribute: .bottom,
                    multiplier: 1, constant: 0),
                NSLayoutConstraint(
                    item: ratingView,
                    attribute: .right,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: ratingContainer,
                    attribute: .right,
                    multiplier: 1, constant: 0),
                ])
        }
        
        
      
        
    
    }
    
    
    func setup(object: Store)  {
        
        
      
        
        self.title.text = object.name
        self.address.text = object.address
        
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        // localize to your grouping and decimal separator
        formatter.locale = Locale.current
        
        let number = NSNumber(value: object.votes)
     
        
        if let value = formatter.string(from: number){
             self.ratingView.text = "\(value) (\(object.nbr_votes)) "
        }else{
            self.ratingView.text = "\(object.votes) (\(object.nbr_votes)) "
        }
       
        self.ratingView.rating = object.votes
        
        self.addressCover.frame = self.address.frame
      
        //set image
        
        if object.listImages.count > 0 {
            
           
            if let first = object.listImages.first {
                
                let url = URL(string: first.url500_500)
              
                self.image.kf.indicatorType = .activity
                self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
            }else{
                if let img = UIImage(named: "default_store_image") {
                    self.image.image = img
                }
            }
        }else{
            
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
        
        
        
        if object.lastOffer != "" {
            lastOffer.isHidden = false
            self.lastOffer.text = object.lastOffer
        }else{
            lastOffer.isHidden = true
        }
        
        
        if object.nbrOffers > 0 {
           
            self.offers.isHidden = false
            self.offers.text = "\(object.nbrOffers) \("offers".localized)"
         
        }else{
            self.offers.isHidden = true
        }
        
        
        let distance = object.distance.calculeDistance()
        self.distance.text = distance.getCurrent(type: Distance.Types.Kilometers)
        
        
        if object.featured == 1 {
            self.featured.isHidden = false
        }else {
            self.featured.isHidden = true
        }
        
        
        
    }
    
    
    let ratingView: CosmosView = {
        
        
       
        let cosmosView = CosmosView()
        
        cosmosView.rating = 0
        
        // Change the text
        cosmosView.text = " 0 (0)"
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
