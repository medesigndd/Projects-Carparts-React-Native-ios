//
//  DiscussionCell.swift
//  NearbyStores
//
//  Created by Amine on 6/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class DiscussionCell: UICollectionViewCell {

    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var notification: EdgeLabel!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var gradienView: GradientBGView!
    
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Colors.highlightedGray : UIColor.white
        }
    }

    
    func setupSettings()  {
        
        //distance tag
        notification.leftTextInset = 3
        notification.rightTextInset = 3
        notification.bottomTextInset = 3
        notification.topTextInset = 3
        notification.layer.masksToBounds = false
        notification.layer.cornerRadius = 5
        notification.clipsToBounds = true
        
        
        
        date.backgroundColor = Colors.white
        date.layer.masksToBounds = false
        date.layer.cornerRadius = 5
        date.clipsToBounds = true
        
    
        image.contentMode = .scaleAspectFill
        
        image.layer.borderWidth = 2
        image.layer.masksToBounds = false
        image.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
        
        
        if Utils.isRTL(){
            
            message.textAlignment = .right
            
            let startColor = gradienView.startColor
            let endColor = gradienView.endColor
        
            gradienView.startColor = endColor
            gradienView.endColor = startColor
            
            gradienView.alpha = CGFloat(0.7)
            
        }
      
    
        
    }
    
    func setup(object: Discussion)  {
        
        
        self.name.text = object.senderUser?.name
        
        let date = DateUtils.getPreparedDateDT(dateUTC: object.createdAt)
        self.date.text = date
        
        if object.nbrMessages > 0 {
            self.notification.isHidden = false
            self.notification.text = String(object.nbrMessages)
        }else{
            self.notification.isHidden = true
        }
        
        self.message.text = "Sent message".localized
        if object.messages.count > 0 {
            if let message = object.messages.first {
                  self.message.text = message.message
            }
        }
    
        //set image
        if let image = object.senderUser?.images {
            
            let url = URL(string: image.url100_100)
            
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
        }else{
            if let img = UIImage(named: "profile_placeholder") {
                self.image.image = img
            }
        }
        
        
    }
    
    
}
